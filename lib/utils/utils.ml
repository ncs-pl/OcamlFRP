(*************************************************************************)
(*                                                                       *)
(*                                OCamlFRP                               *)
(*                                                                       *)
(* Copyright (C) 2025  Frédéric Dabrowski                                *)
(* All rights reserved.  This file is distributed under the terms of     *)
(* the GNU Lesser General Public License version 3.                      *)
(* You should have received a copy of the GNU General Public License     *)
(* along with this program.  If not, see <https://www.gnu.org/licenses/>.*)
(*************************************************************************)

open Format 
let show (pp : formatter -> 'a -> unit) (m : string option) (l : 'a list) : unit =
  let m = match m with None -> "" | Some s -> s in
  Format.fprintf std_formatter "%s \n %a \n" m 
    (pp_print_list ?pp_sep:(Some pp_print_space) pp) l

let curry f x y = f (x,y)

let uncurry f (x,y) = f x y

let (<<) g f x = g(f(x));;

let const c = fun _ -> c

let swap (x,y) = (y,x)

let dup x = (x,x)

let mapleft (f : 'a -> 'b) (p : 'a * 'c) = 
  let (a,c) = p in (f a, c)
    
let mapright (f : 'a -> 'b) (p : 'c * 'a) = 
  let (c,a) = p in (c,f a)

let permutright : ('a * 'b) * 'c -> 'a * ('b * 'c) =
  fun ((a,b),c) -> (a, (b,c))

let permutleft : 'a * ('b * 'c) -> ('a * 'b) * 'c =
  fun (a,(b,c)) -> ((a,b),c)
  
  