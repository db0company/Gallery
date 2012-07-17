(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Module to display a pretty images gallery for Ocsigen         *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

open Eliom_content
open Html5.D
open Eliom_parameter

(* ************************************************************************** *)
(* Initialization                                                             *)
(* ************************************************************************** *)

(* This function must be called in the HTML header with the directory where   *)
(* the gallery css file is as an argument.                                    *)
val load_css : string list -> [> Html5_types.link ] Eliom_content_core.Html5.elt
val load_css_str : string -> [> Html5_types.link ] Eliom_content_core.Html5.elt
val load_css_path : Pathname.t -> [> Html5_types.link ] Eliom_content_core.Html5.elt

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

(* Return a div containing a pretty displaying of a gallery                   *)
val viewer : ?title:string -> string list -> [> Html5_types.div ] Eliom_content.Html5.D.elt
val viewer_str : ?title:string -> string -> [> Html5_types.div ] Eliom_content.Html5.D.elt
val viewer_path : ?title:string -> Pathname.t -> [> Html5_types.div ] Eliom_content.Html5.D.elt

