(** Structured logging with functors for bot observability *)

(** Log level hierarchy *)
type level =
  | Debug  (** Detailed diagnostic information *)
  | Info   (** General informational messages *)
  | Warn   (** Warning messages for potential issues *)
  | Error  (** Error messages for failures *)

(** Compare levels for filtering *)
let level_to_int = function
  | Debug -> 0
  | Info -> 1
  | Warn -> 2
  | Error -> 3

let level_passes ~min_level ~msg_level =
  level_to_int msg_level >= level_to_int min_level

let level_to_string = function
  | Debug -> "DEBUG"
  | Info -> "INFO"
  | Warn -> "WARN"
  | Error -> "ERROR"

(** Backend signature for implementing log outputs *)
module type Backend = sig
  type t

  val create : unit -> t
  val write : t -> level:level -> src:string -> msg:string -> unit
  val writef : t -> level:level -> src:string -> ('a, Format.formatter, unit, unit) format4 -> 'a
  val close : t -> unit
end

(** Configuration for logger behavior *)
module type Config = sig
  val src : string
  val level : level
end

(** Logger signature - the interface for logging *)
module type S = sig
  val debug : ('a, Format.formatter, unit, unit) format4 -> 'a
  val info : ('a, Format.formatter, unit, unit) format4 -> 'a
  val warn : ('a, Format.formatter, unit, unit) format4 -> 'a
  val error : ('a, Format.formatter, unit, unit) format4 -> 'a

  val debug_kv : string -> (string * string) list -> unit
  val info_kv : string -> (string * string) list -> unit
  val warn_kv : string -> (string * string) list -> unit
  val error_kv : string -> (string * string) list -> unit

  val debug' : (unit -> string) -> unit
  val info' : (unit -> string) -> unit
  val warn' : (unit -> string) -> unit
  val error' : (unit -> string) -> unit

  val is_debug_enabled : unit -> bool
  val is_info_enabled : unit -> bool
end

(** Logger functor implementation *)
module Make (B : Backend) (C : Config) : S = struct
  (* Backend instance - created lazily on first use *)
  let backend_ref = ref None

  let get_backend () =
    match !backend_ref with
    | Some b -> b
    | None ->
        let b = B.create () in
        backend_ref := Some b;
        b

  (* Helper to format key-value pairs *)
  let format_kv kvs =
    if kvs = [] then ""
    else
      let pairs = List.map (fun (k, v) -> Format.sprintf "%s=%s" k v) kvs in
      " [" ^ String.concat ", " pairs ^ "]"

  (* Check if a level should be logged *)
  let should_log msg_level =
    level_passes ~min_level:C.level ~msg_level

  (* Level check helpers *)
  let is_debug_enabled () = should_log Debug
  let is_info_enabled () = should_log Info

  (* Core logging functions with level filtering *)
  let debug fmt =
    if should_log Debug then
      Format.kasprintf (fun msg ->
        let b = get_backend () in
        B.write b ~level:Debug ~src:C.src ~msg
      ) fmt
    else
      Format.ikfprintf (fun _fmt -> ()) Format.std_formatter fmt

  let info fmt =
    if should_log Info then
      Format.kasprintf (fun msg ->
        let b = get_backend () in
        B.write b ~level:Info ~src:C.src ~msg
      ) fmt
    else
      Format.ikfprintf (fun _fmt -> ()) Format.std_formatter fmt

  let warn fmt =
    if should_log Warn then
      Format.kasprintf (fun msg ->
        let b = get_backend () in
        B.write b ~level:Warn ~src:C.src ~msg
      ) fmt
    else
      Format.ikfprintf (fun _fmt -> ()) Format.std_formatter fmt

  let error fmt =
    if should_log Error then
      Format.kasprintf (fun msg ->
        let b = get_backend () in
        B.write b ~level:Error ~src:C.src ~msg
      ) fmt
    else
      Format.ikfprintf (fun _fmt -> ()) Format.std_formatter fmt

  (* Structured logging with key-value pairs *)
  let debug_kv msg kvs =
    if should_log Debug then
      let b = get_backend () in
      B.write b ~level:Debug ~src:C.src ~msg:(msg ^ format_kv kvs)

  let info_kv msg kvs =
    if should_log Info then
      let b = get_backend () in
      B.write b ~level:Info ~src:C.src ~msg:(msg ^ format_kv kvs)

  let warn_kv msg kvs =
    if should_log Warn then
      let b = get_backend () in
      B.write b ~level:Warn ~src:C.src ~msg:(msg ^ format_kv kvs)

  let error_kv msg kvs =
    if should_log Error then
      let b = get_backend () in
      B.write b ~level:Error ~src:C.src ~msg:(msg ^ format_kv kvs)

  (* Lazy evaluation helpers *)
  let debug' f =
    if should_log Debug then
      let msg = f () in
      let b = get_backend () in
      B.write b ~level:Debug ~src:C.src ~msg

  let info' f =
    if should_log Info then
      let msg = f () in
      let b = get_backend () in
      B.write b ~level:Info ~src:C.src ~msg

  let warn' f =
    if should_log Warn then
      let msg = f () in
      let b = get_backend () in
      B.write b ~level:Warn ~src:C.src ~msg

  let error' f =
    if should_log Error then
      let msg = f () in
      let b = get_backend () in
      B.write b ~level:Error ~src:C.src ~msg
end

(** Console backend - outputs to stderr with colors *)
module Console : Backend = struct
  type t = {
    mutex : Mutex.t;
  }

  let create () =
    {
      mutex = Mutex.create ();
    }

  (* ANSI color codes *)
  let color_of_level = function
    | Debug -> "\027[2m"      (* Dim/gray *)
    | Info -> ""              (* Default *)
    | Warn -> "\027[33m"      (* Yellow *)
    | Error -> "\027[31m"     (* Red *)

  let reset_color = "\027[0m"

  (* Get current timestamp in ISO 8601 format *)
  let timestamp () =
    let open Unix in
    let t = gettimeofday () in
    let tm = gmtime t in
    let ms = int_of_float ((t -. floor t) *. 1000.0) in
    Format.sprintf "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ"
      (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
      tm.tm_hour tm.tm_min tm.tm_sec ms

  let write t ~level ~src ~msg =
    Mutex.lock t.mutex;
    let ts = timestamp () in
    let color = color_of_level level in
    let level_str = level_to_string level in
    Format.eprintf "%s[%s] [%s] [%s] %s%s@." color ts level_str src msg reset_color;
    Mutex.unlock t.mutex

  let writef t ~level ~src fmt =
    Format.kasprintf (fun msg ->
      write t ~level ~src ~msg
    ) fmt

  let close _t = ()
end
