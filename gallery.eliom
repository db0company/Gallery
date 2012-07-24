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
(* Gallery Data                                                               *)
(* ************************************************************************** *)

{shared{

module type DATA =
  sig
    type t

    val ndata : Pathname.t -> string -> t
    val path : t -> Pathname.t
    val single_id : t -> string
    val chpath : t -> Pathname.t -> t
  end

module Data : DATA =
  struct
    type t = (Pathname.t * string)

    let ndata p s = (p, s)
    let path (p, _) = p
    let single_id (_, s) = s
    let chpath (p, s) np = (np, s)
  end

open Data
}}

(* ************************************************************************** *)
(* Initialization                                                             *)
(* ************************************************************************** *)

{server{

(* The filename of the CSS stylesheet used by gallery                         *)
  let gallery_css_file = "gallery.css"

(* load_css : string list -> [> Html5_types.link ] Eliom_content_core.Html5.e *)
(* load_css_str : string -> [> Html5_types.link ] Eliom_content_core.Html5.el *)
(* load_css_path : Pathname.t -> [> Html5_types.link ] Eliom_content_core.Htm *)
(* This function must be called in the HTML header with the directory where   *)
(* the gallery css file is as an argument.                                    *)
  let aux_load_css path =
    let gallery_css_path = (Pathname.extend_file path gallery_css_file) in
    css_link ~uri:(make_uri (Eliom_service.static_dir ())
                     (Pathname.to_list gallery_css_path)) ()
  let load_css_path path =
    aux_load_css path
  and load_css_str path_str =
    aux_load_css (Pathname.new_path_of_string path_str)
       and load_css path_list =
    aux_load_css (Pathname.new_path_of_list path_list)

}}

(* ************************************************************************** *)
(* Images tools                                                               *)
(* ************************************************************************** *)

{server{

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

}}

{shared{

(* show_img : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt              *)
(* Return an image node corresponding to the given image                      *)
  let show_img path =
    img
      ~alt:(Pathname.no_extension path)
      ~src:(make_uri
              ~service:(Eliom_service.static_dir ())
              (Pathname.to_list path)) ()

}}

(* ************************************************************************** *)
(* Thumbnails tools                                                           *)
(* ************************************************************************** *)

{shared{

(* Filename used when an image thumbnail does not exists                      *)
  let default_thumbnail = ".default.png"

(* Filename used for sub-directories in the gallery                           *)
   let directory_thumbnail = ".directory.png"

(* thumnail_name : string -> string                                           *)
(* Return the thumbnail filename for a filename without any verification      *)
   let thumbnail_name filename = ".thb_" ^ filename

(* thumbnail_path : Pathname.t -> Pathname.t                                  *)
(* Return the same path but with the thumnail name instead of filename        *)
   let thumbnail_path path =
     Pathname.extend_file (Pathname.parent path)
       (thumbnail_name (Pathname.filename path))

(* default_thumbnail_path : Pathname.t -> Pathname.t                          *)
   let default_thumbnail_path path =
     Pathname.extend (Pathname.parent path) default_thumbnail

(* show_thumbnail : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt        *)
(* Return an image node corresponding to the thumbnail of the given image     *)
   let show_thumbnail path =
     show_img (thumbnail_path path)

}}

(* ************************************************************************** *)
(* Filesystem tools                                                           *)
(* ************************************************************************** *)

{server{

(* /!\ todo: ["static"] must be replace by the static_dir *)
(* relative_to_real : Pathname.t -> string                                    *)
(* Take a path relative to the static_dir and return the real path            *)
  let relative_to_real path =
    (Pathname.to_string (Pathname.concat
                           (Pathname.new_path_of_list ["static"]) path))

}}

{server{

(* img_dir_list : Pathname.t -> (string list * string list)                   *)
(* Browse the given folder name and return two lists :                        *)
(* - The first list contains images filenames                                 *)
(* - The second list contains directories filenames                           *)
  let img_dir_list path =
    let no_hidden_file filename = filename.[0] != '.'
    and is_directory file_path =
      Sys.is_directory (relative_to_real file_path) in
    let rec aux handle acc =
      try
        let file = Unix.readdir handle
        in aux handle (file::acc)
      with End_of_file -> acc in
    let handle = Unix.opendir (relative_to_real path) in
    let filelist = aux handle []
    in (List.filter
          (fun filename ->
            let file_path = Pathname.extend_file path filename in
            no_hidden_file filename && is_img file_path
            && is_directory file_path == false) filelist,
        List.filter
          (fun filename ->
            let file_path = Pathname.extend_file path filename in
            no_hidden_file filename && is_directory file_path) filelist)

}}

(* ************************************************************************** *)
(* Ocsigen various tools                                                      *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Client call server side function                                           *)
(* ************************************************************************** *)

{server{

(* This service is called by the client. It returns the path and a list of    *)
(* files and directory inside this path, so the client can display it.        *)
  let client_to_server_service =
    Eliom_registration.Ocaml.register_post_coservice'
      ~post_params:(string "path" ** string "single_id")
      (fun () (str_path, single_id) ->
        let _ = print_endline ("Request files on server side : " ^ str_path) in
        let path = Pathname.new_path_of_string str_path in
        Lwt.return ((ndata (Pathname.new_path_of_string str_path) single_id),
		    (img_dir_list path)))

}}

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

{client{
let get_element_by_id id =
  let of_opt e = Js.Opt.get e (fun _ -> assert false) in
  of_opt (Dom_html.document##getElementById (Js.string id))
}}

(* ************************************************************************** *)
(* Display full size images                                                   *)
(* ************************************************************************** *)

{client{
  let close_image_handler close_button =
    let remove_div _ =
      Dom.removeChild (Dom_html.document##body)
	(get_element_by_id "fullsize") in
    let open Event_arrows in
        let _ = run (clicks (To_dom.of_div close_button)
		       (arr remove_div)) () in ()
}}

{server{
  let close_image_handler close_button =
    {{close_image_handler %close_button}}
}}

{shared{

  let fullsize_image ?description:(d="") path =
    let description =
      if (String.length d) = 0
      then Pathname.no_extension path
      else d
    and pathlist = Pathname.to_list path
    and close_button = div ~a:[a_class ["close_button"]] [pcdata "X"] in
    let _ = close_image_handler close_button in
    div ~a:[a_class ["fullsize"]; a_id "fullsize"]
      [div ~a:[a_class ["overlayer"]] [];
       div ~a:[a_class ["box"]]
         [img ~a:[a_class ["image"]] ~alt:description
             ~src:(make_uri ~service:(Eliom_service.static_dir ()) pathlist) ();
          div ~a:[a_class ["details"]]
            [pcdata description; close_button]]]

}}

{client{

  let fullsize_handler clicked_thumbnail_s data filename =
    let clicked_thumbnail = To_dom.of_li clicked_thumbnail_s in
    let fullsize_div =
      fullsize_image (Pathname.extend_file (path data) filename) in
    let append_div div _ =
      Dom.appendChild (Dom_html.document##body)
        (Eliom_content.Html5.To_dom.of_div div) in
    let open Event_arrows in
        let _ = run (clicks clicked_thumbnail
                       (arr (append_div fullsize_div))) () in ()
}}

(* ************************************************************************** *)
(* Display thumbnails Client Side                                             *)
(* ************************************************************************** *)

{client{

  let display_image_thumbnail data filename  =
    let file_path = Pathname.extend_file (path data) filename in
    let elem = li [show_thumbnail file_path; pcdata filename] in
    let _ = fullsize_handler elem data filename in
    elem

}}

(* ************************************************************************** *)
(* Directory browsing                                                         *)
(* ************************************************************************** *)

{client{

(* display_img : string -> (string list, string list) -> ul                   *)
(* Take a path, a list of directories and a list of files                     *)
(* and return a div containing a pretty displaying of them.                   *)
  let rec display_img_client data service (file_list, dir_list) =
    let directory_thumb_path = (Pathname.extend (path data) directory_thumbnail) in
    let parent =
      let tmp = li ~a:[a_class ["dir"]; a_id ("dir_parent")]
        [show_img directory_thumb_path; pcdata "< Back"] in
      let _ = dir_handler_client (chpath data (Pathname.parent (path data)))
	tmp service in tmp in
    div ~a:[a_id ("gallery_ct" ^ (single_id data))]
      [p ~a:[a_class ["path"]] [pcdata (Pathname.to_string (path data))];
       ul (parent::(List.map
                (fun filename ->
                  let monli = li ~a:[a_class ["dir"]]
                    [show_img directory_thumb_path; pcdata filename] in
		  dir_handler_client
		    (chpath data (Pathname.extend_file (path data) filename))
                    monli service;
		  monli
		) dir_list)
           @ (List.map (display_image_thumbnail data) file_list))]

(* dir_handler_client : Pathname.t -> string -> post_coservice' -> unit       *)
(* Take the path, the directory button identifier and the                     *)
(* client_to_server_service. It set the handler associeted with the directory *)
(* button, so when you click it, it's showing its content.                    *)
  and dir_handler_client data elem service =
    let get_list_from_server () =
      Eliom_client.call_caml_service
        ~service:service () ((Pathname.to_string (path data)), (single_id data)) in
    let replace_dir (t, file_lists) _ =
      let gallery_div = get_element_by_id ("gallery" ^ (single_id data))
      and to_replace = get_element_by_id ("gallery_ct" ^ (single_id data))
      and new_div = display_img_client data service file_lists in
      (Dom.replaceChild gallery_div (To_dom.of_div new_div) to_replace) in
    let value_binding _ =
      ignore (Lwt.bind (get_list_from_server ())
                (fun result -> Lwt.return (replace_dir result ()))); () in
    let open Event_arrows in
    let _ = run (click (To_dom.of_li elem) >>> (arr value_binding)) () in ()

}}

{server{

(* dir_handler_server : string -> handler                                     *)
(* Take the directory id and return a js action that replace it by its        *)
(* contents when clicked                                                      *)
  let dir_handler_server theli data =
    {{ dir_handler_client %data %theli %client_to_server_service }}

}}

(* ************************************************************************** *)
(* Display thumbnails Server Side                                             *)
(* ************************************************************************** *)

{server{

  let display_directories_thumbnail directory_thumb_path data filename =
    let monli = li ~a:[a_class ["dir"]]
      [show_img directory_thumb_path; pcdata filename]
    in
    let _ = Eliom_service.onload
      (dir_handler_server monli (chpath data (Pathname.extend_file (path data) filename))) in
    monli

   let display_image_thumbnail data filename  =
     let file_path = Pathname.extend_file (path data) filename in
     let elem = li [show_thumbnail file_path; pcdata filename] in
     let _ = Eliom_service.onload {{fullsize_handler %elem %data %filename}} in
     elem

}}

{server{

(* display_img : path -> (string list, string list) -> ul                     *)
(* Take a path and return a list of pictures and directory                    *)
let display_images_server data (file_list, dir_list) =
  let dir_thumb_path = (Pathname.extend (path data) directory_thumbnail) in
  div ~a:[a_id ("gallery_ct" ^ (single_id data))]
    [ul ((List.map (display_directories_thumbnail dir_thumb_path data) dir_list) @
            (List.map (display_image_thumbnail data) file_list))]

}}

(* ************************************************************************** *)
(* Viewer                                                                     *)
(* ************************************************************************** *)

{server{

  let default_gallery_title = "Gallery"

(* viewer : string list -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt    *)
(* viewer_str : string -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt     *)
(* viewer_path : Pathname.t -> [> Html5_types.div ] Eliom_content.Html5.D.elt *)
(* Return a div containing a pretty displaying of a gallery                   *)
   let viewer_path ?title:(title=default_gallery_title) pathname =
     let single_id = Random.self_init (); string_of_int (Random.int 999) in
     div ~a:[a_class["gallery"]; a_id ("gallery" ^ single_id)]
       [h3 ~a:[a_id "title"] [pcdata title];
        display_images_server (ndata pathname single_id) (img_dir_list pathname)]

   let viewer ?title:(t=default_gallery_title) list_path =
     viewer_path ~title:t
       (Pathname.new_path_of_list list_path)
   and viewer_str ?title:(t=default_gallery_title) str_path =
     viewer_path ~title:t
       (Pathname.new_path_of_string str_path)

}}
