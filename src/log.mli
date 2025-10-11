(** Structured logging with functors for bot observability *)

(** Log level hierarchy *)
type level =
  | Debug  (** Detailed diagnostic information *)
  | Info   (** General informational messages *)
  | Warn   (** Warning messages for potential issues *)
  | Error  (** Error messages for failures *)

(** Backend signature for implementing log outputs *)
module type Backend = sig
  type t
  (** Backend state type *)

  val create : unit -> t
  (** [create ()] creates a new backend instance *)

  val write : t -> level:level -> src:string -> msg:string -> unit
  (** [write backend ~level ~src ~msg] writes a log message *)

  val writef : t -> level:level -> src:string -> ('a, Format.formatter, unit, unit) format4 -> 'a
  (** [writef backend ~level ~src fmt ...] writes a formatted log message *)

  val close : t -> unit
  (** [close backend] closes the backend and releases resources *)
end

(** Configuration for logger behavior *)
module type Config = sig
  val src : string
  (** Source name: "Polling", "Api", "Bot", etc. *)

  val level : level
  (** Minimum level to log. Messages below this level are filtered. *)
end

(** Logger signature - the interface for logging *)
module type S = sig
  (** {1 Basic logging functions} *)

  val debug : ('a, Format.formatter, unit, unit) format4 -> 'a
  (** [debug fmt ...] logs a debug message. Only shown if level <= Debug. *)

  val info : ('a, Format.formatter, unit, unit) format4 -> 'a
  (** [info fmt ...] logs an info message. Only shown if level <= Info. *)

  val warn : ('a, Format.formatter, unit, unit) format4 -> 'a
  (** [warn fmt ...] logs a warning message. Only shown if level <= Warn. *)

  val error : ('a, Format.formatter, unit, unit) format4 -> 'a
  (** [error fmt ...] logs an error message. Always shown. *)

  (** {1 Structured logging with key-value pairs} *)

  val debug_kv : string -> (string * string) list -> unit
  (** [debug_kv msg kvs] logs a debug message with key-value pairs *)

  val info_kv : string -> (string * string) list -> unit
  (** [info_kv msg kvs] logs an info message with key-value pairs *)

  val warn_kv : string -> (string * string) list -> unit
  (** [warn_kv msg kvs] logs a warning message with key-value pairs *)

  val error_kv : string -> (string * string) list -> unit
  (** [error_kv msg kvs] logs an error message with key-value pairs *)

  (** {1 Lazy evaluation for expensive computations} *)

  val debug' : (unit -> string) -> unit
  (** [debug' f] logs a debug message by calling [f] only if debug level is enabled *)

  val info' : (unit -> string) -> unit
  (** [info' f] logs an info message by calling [f] only if info level is enabled *)

  val warn' : (unit -> string) -> unit
  (** [warn' f] logs a warning message by calling [f] only if warn level is enabled *)

  val error' : (unit -> string) -> unit
  (** [error' f] logs an error message by calling [f] only if error level is enabled *)

  (** {1 Level checks} *)

  val is_debug_enabled : unit -> bool
  (** [is_debug_enabled ()] returns true if debug logging is enabled *)

  val is_info_enabled : unit -> bool
  (** [is_info_enabled ()] returns true if info logging is enabled *)
end

(** {1 Logger functor} *)

module Make (B : Backend) (C : Config) : S
(** [Make] creates a logger from a backend and configuration.

    Example:
    {[
      module Log = Log.Make (Log.Console) (struct
        let src = "MyModule"
        let level = Info
      end)

      let () =
        Log.info "Started with count=%d" 42;
        Log.debug "Detailed info";  (* Filtered out if level > Debug *)
    ]}
*)

(** {1 Built-in backends} *)

module Console : Backend
(** Console backend - outputs to stderr with colors *)
