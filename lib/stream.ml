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

let destr s =
  let (Str (gen, init)) = s in
  let value, next = gen init in
  value, Str (gen, next)
;;

let head s = fst (destr s)
let tail s = snd (destr s)

let map f s =
  let (Str (s_gen, s_init)) = s in
  let gen state =
    let v, next = s_gen state in
    f v, next
  in
  Str (gen, s_init)
;;

let apply f s =
  let (Str (f_gen, f_init)) = f in
  let (Str (s_gen, s_init)) = s in
  let gen (f_state, s_state) =
    let f_value, next_f_state = f_gen f_state in
    let s_value, next_s_state = s_gen s_state in
    f_value s_value, (next_f_state, next_s_state)
  in
  let init = f_init, s_init in
  Str (gen, init)
;;

let produce g s = Str (g, s)

let coiterate f s =
  let gen x =
    let x' = f x in
    x, x'
  in
  produce gen s
;;

let constant x = coiterate (Fun.const x) x

let rec perform s f n =
  if n > 0
  then (
    let (Str (gen, init)) = s in
    let value, next = gen init in
    f value;
    perform (Str (gen, next)) f (n - 1))
;;

let rec consume s p d =
  let (Str (gen, init)) = s in
  let value, next = gen init in
  let bool = p value in
  match d with
  | None -> ()
  | Some t ->
    Thread.delay t;
    if bool then consume (Str (gen, next)) p d
;;

let stream_of_list l a =
  let gen list =
    match list with
    | [] -> a, list
    | h :: t -> h, t
  in
  Str (gen, l)
;;

let rec list_of_stream s n =
  let (Str (gen, init)) = s in
  if n > 0
  then (
    let value, next = gen init in
    (* TODO(nico): final recursion to obtain tail-call optimization *)
    value :: list_of_stream (Str (gen, next)) (n - 1))
  else []
;;
