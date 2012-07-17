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
(* Client call server side function                                           *)
(* ************************************************************************** *)

{server{

(* This service is called by the client. It returns the path and a list of    *)
(* files and directory inside this path, so the client can display it.        *)
  let client_to_server_service =
    Eliom_registration.Ocaml.register_post_coservice'
      ~post_params:(string "path")
      (fun () str_path ->
        let _ = print_endline ("Request files on server side : " ^ str_path) in
        let path = Pathname.new_path_of_string str_path in
        Lwt.return (path, (img_dir_list path)))

}}

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Display full size images                                                   *)
(* ************************************************************************** *)

{shared{

  let fullsize_image ?description:(d="") path =
    let description =
      if (String.length d) = 0
      then Pathname.no_extension path
      else d
    and pathlist = Pathname.to_list path in
    div ~a:[a_class ["fullsize"]]
      [div ~a:[a_class ["overlayer"]] [];
       div ~a:[a_class ["box"]]
         [img ~a:[a_class ["image"]] ~alt:description
             ~src:(make_uri ~service:(Eliom_service.static_dir ()) pathlist) ();
          div ~a:[a_class ["details"]]
            [pcdata description;
             div ~a:[a_class ["close_button"]] [pcdata "X"]]]]

}}

{client{

  let fullsize_handler clicked_thumbnail_s path filename =
    let clicked_thumbnail = To_dom.of_li clicked_thumbnail_s in
    let open Event_arrows in
        let fullsize_div =
          fullsize_image (Pathname.extend_file path filename) in
        let append_div div _ =
          Dom.appendChild (Dom_html.document##body)
            (Eliom_content.Html5.To_dom.of_div div) in
        let _ = run (clicks clicked_thumbnail
                       (arr (append_div fullsize_div))) () in ()
}}

(* ************************************************************************** *)
(* Display thumbnails Client Side                                             *)
(* ************************************************************************** *)

{client{

  let display_image_thumbnail path filename  =
    let file_path = Pathname.extend_file path filename in
    let elem = li [show_thumbnail file_path; pcdata filename] in
    let _ = fullsize_handler elem path filename in
    elem

}}

(* ************************************************************************** *)
(* Directory browsing                                                         *)
(* ************************************************************************** *)

{client{

(* display_img : string -> (string list, string list) -> ul                   *)
(* Take a path, a list of directories and a list of files                     *)
(* and return a div containing a pretty displaying of them.                   *)
  let rec display_img_client path (file_list, dir_list) =
    let _ = dir_handler_client (Pathname.parent path) "dir_parent"
            (* todo: miss service here*) in
    let directory_thumb_path = (Pathname.extend path directory_thumbnail) in
    div ~a:[a_id "gallery_ct"]
      [p ~a:[a_class ["path"]] [pcdata (Pathname.to_string path)];
       ul ([li ~a:[a_class ["dir"]; a_id ("dir_parent")]
               [show_img directory_thumb_path; pcdata "< Back"]]
           @ (List.map
                (fun filename ->
                  let _ = dir_handler_client (Pathname.extend_file path filename)
                    ("dir_" ^ filename) (* todo: miss service here*) in
                  li ~a:[a_class ["dir"]; a_id ("dir_" ^ filename)]
                    [show_img directory_thumb_path; pcdata filename]) dir_list)
           @ (List.map (display_image_thumbnail path) file_list))]

(* dir_handler_client : Pathname.t -> string -> post_coservice' -> unit       *)
(* Take the path, the directory button identifier and the                     *)
(* client_to_server_service. It set the handler associeted with the directory *)
(* button, so when you click it, it's showing its content.                    *)
  and dir_handler_client path dir_id service =
    let get_list_from_server () =
      Eliom_client.call_caml_service
        ~service:service () (Pathname.to_string path)
    and of_opt e = Js.Opt.get e (fun _ -> assert false) in
    let replace_dir (path, file_lists) _ =
      let gallery_div =
        of_opt (Dom_html.document##getElementById (Js.string "gallery"))
      and to_replace =
        of_opt (Dom_html.document##getElementById (Js.string "gallery_ct"))
      and new_div = display_img_client path file_lists in
      (Dom.replaceChild gallery_div (To_dom.of_div new_div) to_replace) in
    let value_binding _ =
      ignore (Lwt.bind (get_list_from_server ())
                (fun result -> Lwt.return (replace_dir result ()))); () in
    let open Event_arrows in
        let elem =
          of_opt (Dom_html.document##getElementById (Js.string dir_id)) in
        let _ = run (click elem >>> (arr value_binding)) () in ()

}}

{server{

(* dir_handler_server : string -> handler                                     *)
(* Take the directory id and return a js action that replace it by its        *)
(* contents when clicked                                                      *)
  let dir_handler_server path =
    let dir_id = "dir_" ^ (Pathname.filename path) in
    {{ dir_handler_client %path %dir_id %client_to_server_service }}

}}

(* ************************************************************************** *)
(* Display thumbnails Server Side                                             *)
(* ************************************************************************** *)

{server{

  let display_directories_thumbnail directory_thumb_path path filename =
    let _ = Eliom_service.onload
      (dir_handler_server (Pathname.extend_file path filename)) in
    li ~a:[a_class ["dir"]; a_id ("dir_" ^ filename)]
      [show_img directory_thumb_path; pcdata filename]

   let display_image_thumbnail path filename  =
     let file_path = Pathname.extend_file path filename in
     let elem = li [show_thumbnail file_path; pcdata filename] in
     let _ = Eliom_service.onload {{fullsize_handler %elem %path %filename}} in
     elem

}}

{server{

(* display_img : path -> (string list, string list) -> ul                     *)
(* Take a path and return a list of pictures and directory                    *)
let display_images_server path (file_list, dir_list) =
  let directory_thumb_path = (Pathname.extend path directory_thumbnail) in
  div ~a:[a_id "gallery_ct"]
    [ul ((List.map (display_directories_thumbnail
                      directory_thumb_path path) dir_list) @
            (List.map (display_image_thumbnail path) file_list))]

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
   let viewer_path ?title:(t=default_gallery_title) path =
     div ~a:[a_class["gallery"]; a_id "gallery"]
       [h3 ~a:[a_id "title"] [pcdata t];
        display_images_server path (img_dir_list path)]

   let viewer ?title:(t=default_gallery_title) list_path =
     viewer_path ~title:t
       (Pathname.new_path_of_list list_path)
   and viewer_str ?title:(t=default_gallery_title) str_path =
     viewer_path ~title:t
       (Pathname.new_path_of_string str_path)

}}
