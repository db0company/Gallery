(* ************************************************************************** *)
(* Project: PathName                                                          *)
(* Description: Module to manipulate filesystem paths                         *)
(* Author: David "Thor" GIRON <thor@epitech.net>                              *)
(* Modified by: db0 (db0company@gmail.com, http://db0.fr/)                    *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t

(* ************************************************************************** *)
(* Values                                                                     *)
(* ************************************************************************** *)

(* The directory separator (Example: "/" for Unix)                            *)
val sep : string

(* An empty path                                                              *)
val empty : t

(* ************************************************************************** *)
(* Constructors                                                               *)
(* ************************************************************************** *)

(* Return a new empty path                                                    *)
val new_path : unit -> t

(* Return a new path initialized using a string                               *)
val new_path_of_string : string -> t

(* Return a new path initialized using a list                                 *)
val new_path_of_list : string list -> t

(* ************************************************************************** *)
(* Operators                                                                  *)
(* ************************************************************************** *)

(* Concatenate two paths and return the result                                *)
val concat : t -> t -> t

(* Extend path dir, appends the directory to the path                         *)
val extend : t -> string -> t
  
(* Extend path with a filename. Works only with raw filename, not paths.      *)
(* More efficient than extend.                                                *)
val extend_file : t -> string -> t

(* ************************************************************************** *)
(* Get                                                                        *)
(* ************************************************************************** *)

(* Return a string corresponding to the path                                  *)
val to_string : t -> string

(* Return a list of strings corresponding to the path                         *)
val to_list : t -> string list
