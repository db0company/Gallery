(* ************************************************************************** *)
(* Project: PathName                                                          *)
(* Description: Module to manipulate filesystem paths                         *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

(* * List of each dir names in reverse order                                  *)
(* * The string representation of the path                                    *)
type t = (string list * string)

(* ************************************************************************** *)
(* Values                                                                     *)
(* ************************************************************************** *)

(* sep : string                                                               *)
(* The directory separator (Example: "/" for Unix)                            *)
let sep = "/"(* Filename.dir_sep *)

(* empty : t                                                                  *)
(* An empty path                                                              *)
let empty = ([], "")

(* ************************************************************************** *)
(* Constructors                                                               *)
(* ************************************************************************** *)

(* new_path : unit -> t                                                       *)
(* Return a new empty path                                                    *)
let new_path () = empty

(* new_path_of_string : string -> t                                           *)
(* Return a new path initialized using a string                               *)
let new_path_of_string spath =
  let dirlist = Split.split spath sep in
  let dirstr = String.concat sep dirlist in
  ((List.rev dirlist), dirstr)

(* new_path_of_list : string list -> t                                        *)
(* Return a new path initialized using a list                                 *)
let new_path_of_list lpath =
  (List.rev lpath, String.concat sep lpath)

(* ************************************************************************** *)
(* Operators                                                                  *)
(* ************************************************************************** *)

(* concat : t -> t -> t                                                       *)
(* Concatenate two paths and return the result                                *)
let concat (l1, s1) (l2, s2) =
  ((l2 @ l1), (s1 ^ sep ^ s2))

(* extend : t -> string -> t                                                  *)
(* Extend path dir, appends the directory to the path                         *)
let extend path extdir =
  concat path (new_path_of_string extdir)
  
(* extend_file : t -> string -> t                                             *)
(* Extend path with a filename. Works only with raw filename, not paths.      *)
(* More efficient than extend.                                                *)
let extend_file (l, s) filename =
  ((filename::l), (s ^ sep ^ filename))

(* ************************************************************************** *)
(* Get                                                                        *)
(* ************************************************************************** *)

(* to_string : t -> string                                                    *)
(* Return a string corresponding to the path                                  *)
let to_string (l, s) = s

(* to_list : t -> string list                                                 *)
(* Return a list of strings corresponding to the path                         *)
let to_list (l, s) = List.rev l

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* filename : t -> string                                                     *)
(* Return the filename without the rest of the path                           *)
let filename (l, _) = List.hd l

(* parent : t -> t                                                            *)
(* Return the path without the last element                                   *)
(* Example: "foo/bar/baz" -> "foo/bar"                                        *)
let parent (l, _) =
  let new_list = List.tl l in
  (new_list, String.concat sep new_list)

(* extension : t -> string                                                    *)
(* Return the extansion of the given filename                                 *)
(* Example : "document.pdf" -> "pdf"                                          *)
let extension path =
  let f = filename path in
  let start = try (String.rindex f '.') + 1 with Not_found -> 0
  in try String.sub f start ((String.length f) - start)
    with Invalid_argument s -> ""

(* no_extension : t -> string                                                 *)
(* Return filename without its extension                                      *)
(* Example : "/foo/bar/document.pdf" -> "document"                            *)
let no_extension path =
  let f = filename path in
  let size =
    try (String.rindex f '.') with Not_found -> -1
  in try String.sub f 0 size with Invalid_argument s -> f
