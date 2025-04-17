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

(** {1 Streams} *)

(** ['a stream] represents a type of stream of values of type ['a], which is an infinite
    sequence of values of type ['a].  It is a pair whose first value is a generator
    function which given a state returns a value and the next state, and second value
    is the initial state in the stream. *)
type 'a stream = Str : ('s -> 'a * 's) * 's -> 'a stream

(** [destr s] deconstructs stream [s] into a pair containing its head and its tail. *)
val destr : 'a stream -> 'a * 'a stream

(** [head s] returns the head of stream [s]. *)
val head : 'a stream -> 'a

(** [head s] returns the tail of stream [s]. *)
val tail : 'a stream -> 'a stream

(** [map f s] constructs a stream by applying function [f] to values of stream [s]. *)
val map : ('a -> 'b) -> 'a stream -> 'b stream

(** [apply f s] constructs a new stream by applying functions from stream of function
    [f] to the values of stream [s]. *)
val apply : ('a -> 'b) stream -> 'a stream -> 'b stream

(** [produce g s] constructs a stream from generator function [g] and
    initial state [s]. *)
val produce : ('s -> 'a * 's) -> 's -> 'a stream

(* TODO(nico): ????
(** [fold f x] generates a stream by iteratively applying the function [f] 
    to the current value, starting with [x]. s*)
*)

(** [coiterate f s] constructs a stream using the coiterator [(f, s)], 
    where [f] is the function and [s] is the initial state. *)
val coiterate : ('a -> 'a) -> 'a -> 'a stream

(** [constant x] returns a constant stream where every element has the value x. *)
val constant : 'a -> 'a stream

(** [perform s f n] consumes stream [s], applying function [f] (with side-effects)
    on [n] values of [s]. *)
val perform : 'a stream -> ('a -> unit) -> int -> unit

(** [consume s p d] consumes the values from stream [s] as long as the values validates
    predicates [p].  An optional delay [d] can be passed to wait sleep between two
    consumption. *)
val consume : 'a stream -> ('a -> bool) -> float option -> unit

(** [stream_of_list l a] constructs a stream from the elements of list [l], followed
    by value [a] once every element of [l] was streamed. *)
val stream_of_list : 'a list -> 'a -> 'a stream

(** [list_of_stream s n] constructs a list of [n] values from stream [s]. *)
val list_of_stream : 'a stream -> int -> 'a list
