(* JSON forward compatibility utilities.

   This module provides utilities for preserving unknown JSON fields during
   deserialization, enabling forward compatibility when new fields are added
   to the Telegram Bot API without requiring immediate library updates.

   Example usage:

     type t = {
       known_field : string;
       unknown_fields : Unknown_fields.t;
     }

     let of_yojson j = match j with
       | `Assoc fields ->
           let unknown = Unknown_fields.create () in
           let known_field = ... in
           (* Mark field as known: *)
           Unknown_fields.mark_known unknown "known_field";
           (* Capture remaining unknown fields: *)
           let unknown_fields = Unknown_fields.capture unknown fields in
           Ok { known_field; unknown_fields }
       | _ -> Error "Expected object"

     let to_yojson t =
       `Assoc ([
         ("known_field", `String t.known_field);
       ] @ Unknown_fields.to_assoc t.unknown_fields)
*)

module Unknown_fields : sig
  (** Internal tracker for marking known fields during deserialization. *)
  type tracker

  (** Type representing unknown JSON fields preserved during deserialization.
      This is simply an association list of field names to JSON values. *)
  type t = (string * Yojson.Safe.t) list

  (** The empty set of unknown fields. *)
  val empty : t

  (** Check if there are any unknown fields. *)
  val is_empty : t -> bool

  (** Create an unknown fields tracker. *)
  val create : unit -> tracker

  (** Mark a field name as known (processed). *)
  val mark_known : tracker -> string -> unit

  (** Capture all fields that weren't marked as known. *)
  val capture : tracker -> (string * Yojson.Safe.t) list -> t

  (** Convert unknown fields back to association list for serialization. *)
  val to_assoc : t -> (string * Yojson.Safe.t) list

  (** Get the number of unknown fields. *)
  val count : t -> int

  (** Pretty-printer for debugging. *)
  val pp : Format.formatter -> t -> unit
end
