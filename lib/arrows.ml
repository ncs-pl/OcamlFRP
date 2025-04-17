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

type ('a, 'b) sf = SF : ('s -> 'a -> 'b * 's) * 's -> ('a, 'b) sf

let arr : ('a -> 'b) -> ('a, 'b) sf =
  fun f ->
  let h () x = f x, () in
  SF (h, ())
;;

let ( >>> ) (SF (f, f0)) (SF (g, g0)) =
  let h (s1, s2) x =
    let x', s1' = f s1 x in
    let x'', s2' = g s2 x' in
    x'', (s1', s2')
  in
  let h0 = f0, g0 in
  SF (h, h0)
;;

let first (SF (f, f0)) =
  let h s (x1, x2) =
    let x1', s' = f s x1 in
    (x1', x2), s'
  in
  SF (h, f0)
;;

let second (SF (f, f0)) =
  let h s (x1, x2) =
    let x2', s' = f s x2 in
    (x1, x2'), s'
  in
  SF (h, f0)
;;

let parallel (SF (f, f0)) (SF (g, g0)) =
  let h (s1, s2) (x1, x2) =
    let x1', s1' = f s1 x1 in
    let x2', s2' = g s2 x2 in
    (x1', x2'), (s1', s2')
  in
  let h0 = f0, g0 in
  SF (h, h0)
;;

let fanout (SF (f, f0)) (SF (g, g0)) =
  let h (s1, s2) a =
    let b, s1' = f s1 a in
    let c, s2' = g s2 a in
    (b, c), (s1', s2')
  in
  let h0 = f0, g0 in
  SF (h, h0)
;;

let left (SF (f, f0)) =
  let h s = function
    | Either.Left v ->
      let v', s' = f s v in
      Either.Left v', s'
    | Either.Right v -> Either.Right v, s
  in
  SF (h, f0)
;;

let right (SF (f, f0)) =
  let h s = function
    | Either.Left v -> Either.left v, s
    | Either.Right v ->
      let v', s' = f s v in
      Either.Right v', s'
  in
  SF (h, f0)
;;

let choice (SF (f, f0)) (SF (g, g0)) =
  let h (s1, s2) = function
    | Either.Left v ->
      let v', s1' = f s1 v in
      Either.Left v', (s1', s2)
    | Either.Right v ->
      let v', s2' = g s2 v in
      Either.Right v', (s1, s2')
  in
  let h0 = f0, g0 in
  SF (h, h0)
;;

let fanin (SF (f, f0)) (SF (g, g0)) =
  let h (s1, s2) = function
    | Either.Left v ->
      let v', s1' = f s1 v in
      v', (s1', s2)
    | Either.Right v ->
      let v', s2' = g s2 v in
      v', (s1, s2')
  in
  let h0 = f0, g0 in
  SF (h, h0)
;;

let loop (SF (f, f0)) k =
  let h (s, k) x =
    let (x', k'), s' = f s (x, k) in
    x', (s', k')
  in
  let h0 = f0, k in
  SF (h, h0)
;;

let lift (SF (f, f0)) (Str (g, g0)) =
  let h (s1, s2) =
    let x, s1' = g s1 in
    let x', s2' = f s2 x in
    x', (s1', s2')
  in
  let h0 = g0, f0 in
  Str (h, h0)
;;

module Arr = struct
  let id =
    let f s x = x, s in
    SF (f, ())
  ;;

  let const x =
    let f s _ = x, s in
    SF (f, ())
  ;;

  let dup =
    let f s x = (x, x), s in
    SF (f, ())
  ;;

  let delay x = loop (arr Utils.swap) x
end
