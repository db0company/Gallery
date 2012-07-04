(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Module to display a pretty images gallery for Ocsigen         *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

{shared{
open Eliom_content
open Html5
open Html5.D
open Eliom_parameter
}}

(* ************************************************************************** *)
(* Initialization                                                             *)
(* ************************************************************************** *)

(* The filename of the CSS stylesheet used by gallery                         *)
let gallery_css_file = "gallery.css"

(* load_css : string list -> [> Html5_types.link ] Eliom_content_core.Html5.e *)
(* load_css_str : string -> [> Html5_types.link ] Eliom_content_core.Html5.el *)
(* load_css_path : Pathname.t -> [> Html5_types.link ] Eliom_content_core.Htm *)
(* This function must be called in the HTML header with the directory where   *)
(* the "gallery.css" is as an argument.                                       *)
let aux_load_css path =
  css_link
    ~uri:(make_uri (Eliom_service.static_dir ())
  	    (Pathname.to_list path)) ()
let load_css_path path =
  aux_load_css (Pathname.extend_file path gallery_css_file)
let load_css_str path_str =
  aux_load_css
    (Pathname.extend_file (Pathname.new_path_of_string path_str)
       gallery_css_file)
let load_css path_list =
  aux_load_css
    (Pathname.extend_file (Pathname.new_path_of_list path_list)
       gallery_css_file)

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
(* Filesystem tools                                                           *)
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

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

(* dir_handler : string -> handler                                            *)
(* Take the directory id and return a js action that replace it by its        *)
(* contents when clicked                                                      *)
let dir_handler dir_id =
  let new_div = div [pcdata "hello yes this is dog"] in
  {{

    let of_opt e = Js.Opt.get e (fun _ -> assert false) in

    let replace_dir dir_id _ =
      let gallery_div =
	of_opt (Dom_html.document##getElementById (Js.string "gallery"))
      and to_replace =
	of_opt (Dom_html.document##getElementById (Js.string "gallery_ct")) in
      (Dom.replaceChild gallery_div (To_dom.of_div %new_div) to_replace) in

    let open Event_arrows in
	let elem =
	  of_opt (Dom_html.document##getElementById (Js.string %dir_id)) in
	let _ = run (click elem >>> (arr (replace_dir %dir_id))) () in ()

  }}

(* display_img : path -> ul                                                   *)
(* Take a path and return a list of pictures and directory                    *)
let display_img path =
  let flist = img_dir_list path in
  let dir_list = snd flist
  and file_list = fst flist
  and directory_thumb_path = (Pathname.extend path directory_thumbnail) in
  ul ~a:[a_id "gallery_ct"]
    ((List.map
	(fun filename ->
	  let dir_id = "dir_" ^ filename in
	  let _ = Eliom_service.onload (dir_handler dir_id) in
	  li ~a:[a_class ["dir"]; a_id dir_id]
	    [show_img directory_thumb_path; pcdata filename]) dir_list) @
	(List.map
	   (fun filename ->
 	     let file_path = Pathname.extend_file path filename in
	     li [show_thumbnail file_path; pcdata filename]) file_list))

(* viewer : string list -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt    *)
(* viewer_str : string -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt     *)
(* viewer_path : Pathname.t -> [> Html5_types.div ] Eliom_content.Html5.D.elt *)
(* Return a div containing a pretty displaying of a gallery                   *)
let viewer_path ?title:(t="") path =
  div ~a:[a_class["gallery"]; a_id "gallery"]
    [h3 ~a:[a_id "title"] [pcdata t]; display_img path]

let viewer ?title:(t="") list_path =
  viewer_path ~title:t
    (Pathname.new_path_of_list list_path)
and viewer_str ?title:(t="") str_path =
  viewer_path ~title:t
    (Pathname.new_path_of_string str_path)
