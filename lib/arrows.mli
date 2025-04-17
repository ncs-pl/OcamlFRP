(*************************************************************************)
(*                                                                       *)
(*                                OCamlFRP                               *)
(*                                                                       *)
(* Copyright (C) 2025  Frédéric Dabrowski                                *)
(* Copyright (C) 2025  Nicolas Paul                                      *)
(* All rights reserved.  This file is distributed under the terms of     *)
(* the GNU Lesser General Public License version 3.                      *)
(* You should have received a copy of the GNU General Public License     *)
(* along with this program.  If not, see <https://www.gnu.org/licenses/>.*)
(*************************************************************************)

open Stream

(** {1 Stream functions} *)

(** Type of synchronous functions which consumes values of type [a]
    and produces values of type [b] *)

(** A synchronous function type, or arrow, composed of an inner function a and an
    initial state.  The inner function takes a state and a value, and returns a
    new value and a new state. *)
type ('a, 'b) sf = SF : ('s -> 'a -> 'b * 's) * 's -> ('a, 'b) sf

(** [arr f] transform regular function [f] to a synchronous function. *)
val arr : ('a -> 'b) -> ('a, 'b) sf

(** [f >>> g] composes two synchronous functions [f] and [g]. *)
val ( >>> ) : ('a, 'b) sf -> ('b, 'c) sf -> ('a, 'c) sf

(** [first f] creates a synchronous function that operates on the first element of a
    tuple from synchronous function [f]. *)
val first : ('a, 'b) sf -> ('a * 'c, 'b * 'c) sf

(** [second f] creates a synchronous function that operates on the second element of a
    tuple from synchronous function [f]. *)
val second : ('a, 'b) sf -> ('c * 'a, 'c * 'b) sf

(** [parallel f g] applies synchronous functions [f] and [g] on different data in
    parallel and returns the two results. *)
val parallel : ('a, 'b) sf -> ('c, 'd) sf -> ('a * 'c, 'b * 'd) sf

(** [fanout f g] applies synchronous functions [f] and [g] to the same data and returns
    the two results. *)
val fanout : ('a, 'b) sf -> ('a, 'c) sf -> ('a, 'b * 'c) sf

(** [left f] creates from synchronous function [f] a new synchronous function that
    operates on the left-side of an [Either.t]. *)
val left : ('a, 'b) sf -> (('a, 'c) Either.t, ('b, 'c) Either.t) sf

(** [right f e] creates from synchronous function [f] a new synchronous function that
    operates on the left-side of an [Either.t]. *)
val right : ('a, 'b) sf -> (('c, 'a) Either.t, ('c, 'b) Either.t) sf

(** [choice f g] creates from synchronous functions [f] and [g] a new synchronous
    function [f] which applies [f] to the left side of an [Either.t] and [g] to its
    right side. *)
val choice : ('a, 'c) sf -> ('b, 'd) sf -> (('a, 'b) Either.t, ('c, 'd) Either.t) sf

(** [fanin f g] consumes an [Either.t] and applies synchronous functions [f] or [g]
    given the unwrapped value ([f] for the left side, [g] for the right side). *)
val fanin : ('a, 'b) sf -> ('c, 'b) sf -> (('a, 'c) Either.t, 'b) sf

(* TODO(nico): UNDERSTAND THIS LOOP THING *)

(** [loop f] creates a synchronous function that repeats? *)
val loop : ('a * 'b, 'c * 'b) sf -> 'b -> ('a, 'c) sf

(**[lift f s] creates a stream by applying synchronous function [f] to the elements
   of stream [s]. *)
val lift : ('a, 'b) sf -> 'a stream -> 'b stream

module Arr : sig
  (** [id x] create a synchronous function which returns its input without
      modification. *)
  val id : ('a, 'a) sf

  (** [const x] creates a synchronous function which returns the constant [x]. *)
  val const : 'a -> ('b, 'a) sf

  (** [dup x] creates a synchronous function that duplicates its input. *)
  val dup : ('a, 'a * 'a) sf

  (** [delay d] creates a synchronous function which is one entry late. *)
  val delay : 'a -> ('a, 'a) sf
end
