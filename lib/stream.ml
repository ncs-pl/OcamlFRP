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

type 'a stream = Str : ('state -> 'a * 'state) * 'state -> 'a stream

let destr (Str (f, s)) =
  let x, s' = f s in
  x, Str (f, s')
;;

let head s = fst (destr s)
let tail s = snd (destr s)

let map f (Str (g, g0)) =
  let gen s =
    let x, s' = g s in
    f x, s'
  in
  Str (gen, g0)
;;

let apply (Str (f, f0)) (Str (v, v0)) =
  let h (s1, s2) =
    let x1, s1' = f s1 in
    let x2, s2' = v s2 in
    x1 x2, (s1', s2')
  in
  let h0 = f0, v0 in
  Str (h, h0)
;;

let produce g s = Str (g, s)

let coiterate f s =
  let h x =
    let x' = f x in
    x, x'
  in
  produce h s
;;

let constant x = coiterate (Fun.const x) x

let rec perform (Str (g, g0)) f n =
  if n > 0
  then (
    let x, s' = g g0 in
    f x;
    perform (Str (g, s')) f (n - 1))
;;

let rec consume (Str (f, f0)) p d =
  let value, next = f f0 in
  match d with
  | None -> ()
  | Some t ->
    Thread.delay t;
    if p value then consume (Str (f, next)) p d
;;

let stream_of_list l a =
  let h = function
    | [] as t -> a, t
    | h :: t -> h, t
  in
  Str (h, l)
;;

let rec list_of_stream (Str (f, s)) n =
  if n > 0
  then (
    let x, s' = f s in
    (* TODO(nico): final recursion to obtain tail-call optimization *)
    x :: list_of_stream (Str (f, s')) (n - 1))
  else []
;;
