(* ************************************************************************** *)
(* Project: Split                                                             *)
(* Description: Split for Eliom (function not available on client side)       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

(* split : string -> string -> string list                                    *)
(* Take a string, a string corresponding to a separator (must be a single     *)
(* on client side) and return a list of string with each words                *)
(* Example: (split "apple;banana;cherry" ";") -> ["apple";"banana";"cherry"]  *)

{client{

let split str sep_str =

  let sep = sep_str.[0] in

  let string_of_char_list l =
    let str = String.make (List.length l) '\000' in
    let rec aux idx = function
      | []   -> str
      | c::t -> (String.set str idx c; aux (idx+1) t)
    in aux 0 l in

  let next_word str sep base_idx =
    let rec aux idx acc =
      try
	let c = String.get str idx in
	if (c <> sep)
	then aux (idx + 1) (c::acc)
	else (string_of_char_list (List.rev (acc)), (idx+1))
      with Invalid_argument _ -> (string_of_char_list (List.rev acc), base_idx)
    in aux base_idx [] in

  let rec aux idx acc =
    let (w, next_index) = next_word str sep idx in
    if (idx <> next_index)
    then aux next_index (w::acc)
    else w::acc
  in List.filter (fun str -> str <> "") (List.rev (aux 0 []))

}}

{server{

  let split str sep =
    Str.split (Str.regexp sep) str

}}


