(** Safe units for time and file sizes.

    These newtypes prevent mixing up seconds with milliseconds,
    and file sizes with other integers. *)

(** {1 Duration} *)

module Duration : sig
  (** Duration in seconds. *)
  type t

  val seconds : int -> t
  (** Create from seconds. *)

  val of_int64 : int64 -> t
  (** Create from int64 seconds. *)

  val to_int : t -> int
  (** Get seconds as int. *)

  val to_int64 : t -> int64
  (** Get seconds as int64. *)

  val pp : Format.formatter -> t -> unit
  (** Pretty-print as "42s" or "1m30s" for readability. *)

  val to_string : t -> string

  val to_yojson : t -> Yojson.Safe.t
  (** Encode as integer seconds. *)

  val of_yojson : Yojson.Safe.t -> (t, string) result
end

(** {1 File Size} *)

module File_size : sig
  (** File size in bytes.

      Per Telegram docs: can exceed 2^31 but fits in 52 bits,
      so int64 is safe. *)
  type t

  val bytes : int64 -> t
  (** Create from byte count. *)

  val to_int64 : t -> int64
  (** Get byte count. *)

  val pp : Format.formatter -> t -> unit
  (** Pretty-print as "1.2 MB" with SI units. *)

  val to_string : t -> string

  val to_yojson : t -> Yojson.Safe.t
  (** Encode as integer bytes. *)

  val of_yojson : Yojson.Safe.t -> (t, string) result
end
