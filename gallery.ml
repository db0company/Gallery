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

let load_css path =
  css_link
    ~uri:(make_uri (Eliom_service.static_dir ())
  	    path) ()

(* ************************************************************************** *)
(* Images tools                                                               *)
(* ************************************************************************** *)

(* Known extensions for images files                                          *)
let allowed_extension = ["jpeg";"jpg";"png";"gif";"bmp"]

(* is_img : Pathname.t -> bool                                                *)
(* Check if the given filename has a correct extension corresponding to a     *)
(* known image format                                                         *)
let is_img path =
  let ext = Pathname.extension path in
  List.exists
    (fun str ->
      if (String.compare (String.lowercase ext) (String.lowercase str)) == 0
      then true else false)
    allowed_extension

(* show_img : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt              *)
(* Return an image node corresponding to the given image                      *)
let show_img path =
  img
    ~alt:(Pathname.no_extension path)
    ~src:(make_uri
            ~service:(Eliom_service.static_dir ()) (Pathname.to_list path))
    ()

(* ************************************************************************** *)
(* Thumbnails tools                                                           *)
(* ************************************************************************** *)

(* Filename used when an image thumbnail does not exists                      *)
let default_thumbnail = ".default.png"

(* Filename used for sub-directories in the gallery                           *)
let directory_thumbnail = ".directory.png"

(* thumnail_name : string -> string                                           *)
(* Return the thumbnail filename for a filename without any verification      *)
let thumbnail_name filename = ".thb_" ^ filename

(* show_thumbnail : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt        *)
(* Return an image node corresponding to the thumbnail of the given image     *)
let show_thumbnail path =
  let thumb_path =
    Pathname.extend_file (Pathname.parent path)
      (thumbnail_name (Pathname.filename path)) in
  let which_path =
    let default_thumbnail_path = Pathname.extend (Pathname.parent path)
      default_thumbnail in
    if (Sys.file_exists (Pathname.to_string thumb_path))
    then thumb_path
    else default_thumbnail_path in
  show_img which_path

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

(* img_dir_list : Pathname.t -> (string list * string list)                   *)
(* Browse the given folder name and return two lists :                        *)
(* - The first list contains images filenames                                 *)
(* - The second list contains directories filenames                           *)
let img_dir_list path =
  let no_hidden_file filename = filename.[0] != '.' in
  let rec aux handle acc =
    try
      let file = Unix.readdir handle
      in aux handle (file::acc)
    with End_of_file -> acc in
  let handle = Unix.opendir (Pathname.to_string path) in
  let filelist = aux handle []
  in (List.filter
        (fun filename ->
	  let file_path = Pathname.extend_file path filename in
	  no_hidden_file filename && is_img file_path) filelist,
      List.filter
        (fun filename ->
 	  let file_path = Pathname.extend_file path filename in
	  no_hidden_file filename
	  && Sys.is_directory (Pathname.to_string file_path)) filelist
  )

(* viewer : string list -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt    *)
(* viewer_str : string -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt     *)
(* Return a div containing a pretty displaying of a gallery                   *)
let aux_viewer path = 
  let flist = img_dir_list path in
  let dir_list = snd flist
  and file_list = fst flist
  and directory_thumb_path = (Pathname.extend path directory_thumbnail) in
  div
    ~a:[a_class["hello"]]
    [ul ((List.map
            (fun filename ->
	      li [show_img directory_thumb_path; pcdata filename]) dir_list) @
	    (List.map
	       (fun filename ->
 		 let file_path = Pathname.extend_file path filename in
		 li [show_thumbnail file_path; pcdata filename]) file_list))]

let viewer list_path = aux_viewer (Pathname.new_path_of_list list_path)
and viewer_str str_path = aux_viewer (Pathname.new_path_of_string str_path)
