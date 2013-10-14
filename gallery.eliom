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
(* Gallery files directory service                                            *)
(* ************************************************************************** *)

{server{

exception Invalid_gallery_config

(* gallery_path : Pathname.t                                                  *)
(* /!\ This value can raise an exception that prevents the website to start   *)
let gallery_path =
  let fail () = raise Invalid_gallery_config in
  try match List.hd (Eliom_config.get_config ()) with
    | Simplexmlparser.Element (name, list_attrib, content_list) ->
      if name = "gallery"
      then Pathname.new_path_of_string (List.assoc "dir" list_attrib)
      else fail ()
    | _ -> fail ()
  with _ -> fail ()

(* This service is used by images and css to get the full path on filesytem   *)
(* Return value: string                                                       *)
let files_service =
  Eliom_registration.File.register_service
    ~path:[]
    ~get_params:(suffix (all_suffix "path"))
    (fun path () ->
      let strpath = Pathname.new_path_of_list path in
      Lwt.return
	(Pathname.to_string (Pathname.concat gallery_path strpath)))

}}

(* ************************************************************************** *)
(* OCaml4 not installed yet...                                                *)
(* ************************************************************************** *)

{server{

(* mapi : (int -> 'a -> 'b) -> 'a list -> 'b list                             *)
(* Same as List.map, but the function is applied to the index of the element  *)
(* as first argument (counting from 0), and the element itself as second      *)
(* argument. Not tail-recursive.                                              *)
let mapi f l =
  let rec aux i f = function
    | [] -> []
    | a::l -> let r = f i a in r :: aux (i + 1) f l in
  aux 0 f l

}}

(* ************************************************************************** *)
(* Gallery Data                                                               *)
(* ************************************************************************** *)

{shared{

(* Type to manage images using an index (to browse them using keys)           *)
 type image = (int * string)


(* This simple module is managing Galleries data we need all along Gallery.   *)

module type DATA =
  sig
    type t

(* ndata create a new data containing the original path, the current path and *)
(* the single id.                                                             *)
    val ndata : Pathname.t -> Pathname.t -> string -> t

(* These functions return informations in the data                            *)
    val original_path : t -> Pathname.t
    val path : t -> Pathname.t
    val single_id : t -> string

(* chpath modify the current path inside the data                             *)
    val chpath : t -> Pathname.t -> t

(* full_path return the concatenation of the original and the current pathes  *)
    val full_path : t -> Pathname.t
  end

module Data : DATA =
  struct
    type t = (Pathname.t * Pathname.t * string)

    let ndata op p id = (op, p, id)
    let original_path (op, _, _) = op
    let path (_, p, _) = p
    let single_id (_, _, id) = id
    let chpath (op, p, id) np = (op, np, id)
    let full_path (op, p, _) = Pathname.concat op p
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
    css_link ~uri:(make_uri ~service:files_service
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

(* show_img : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt              *)
(* Return an image node corresponding to the given image                      *)
{client{
  let show_img path files_service =
    img ~alt:(Pathname.no_extension path)
      ~src:(make_uri ~service:files_service (Pathname.to_list path)) ()
}}
{server{
  let show_img path =
    img ~alt:(Pathname.no_extension path)
      ~src:(make_uri ~service:files_service (Pathname.to_list path)) ()
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
}}

(* show_thumbnail : Pathname.t -> [> `Img ] Eliom_pervasives.HTML5.elt        *)
(* Return an image node corresponding to the thumbnail of the given image     *)
{server{
   let show_thumbnail path =
     show_img (thumbnail_path path)
}}
{client{
   let show_thumbnail path service =
     show_img (thumbnail_path path) service
}}

(* ************************************************************************** *)
(* Filesystem tools                                                           *)
(* ************************************************************************** *)

{server{

(* relative_to_real : Pathname.t -> string                                    *)
(* Take a path relative to the static_dir and return the real path            *)
  let relative_to_real path =
    (Pathname.to_string (Pathname.concat gallery_path path))

}}

{server{

(* img_dir_list : data -> (string list * image list)                          *)
(* Browse the given folder name and return two lists :                        *)
(* - The first list contains images filenames                                 *)
(* - The second list contains directories filenames                           *)
  let img_dir_list data =
    let path = full_path data
    and no_hidden_file filename = filename.[0] != '.'
    and is_directory file_path =
      Sys.is_directory (relative_to_real file_path) in
    let rec aux handle acc =
      try
        let file = Unix.readdir handle
        in aux handle (file::acc)
      with End_of_file -> acc
    and handle = Unix.opendir (relative_to_real path) in
    let full_list = List.sort String.compare (aux handle []) in
    let file_list =
      mapi (fun idx img -> (idx, img))
	(List.filter
           (fun filename ->
             let file_path = Pathname.extend_file path filename in
             no_hidden_file filename && is_img file_path
             && is_directory file_path == false) full_list)
    and dir_list =
      (List.filter
         (fun filename ->
           let file_path = Pathname.extend_file path filename in
           no_hidden_file filename && is_directory file_path) full_list) in
    (dir_list, file_list)
}}

(* ************************************************************************** *)
(* Client call server side function                                           *)
(* ************************************************************************** *)

{server{

(* This service is called by the client. It returns the path and a list of    *)
(* files and directory inside this path, so the client can display it.        *)
(* Return value: (data, (string list * image list))                           *)
  let client_to_server_service =
    Eliom_registration.Ocaml.register_post_coservice'
      ~post_params:(string "original_path" ** string "path" ** string "single_id")
      (fun () (op, (sp, si)) ->
	let spp = Pathname.new_path_of_string sp
	and opp = Pathname.new_path_of_string op in
	let data = (ndata opp spp si) in
        Lwt.return (data, (img_dir_list data)))

}}

{client{

(* get_element_by_id : string -> Js elt                                       *)
(* Return the Js form of the element corresponding to the unique identifier   *)
(* The usage of this function is due to a bad design                          *)
let get_element_by_id id =
  let of_opt e = Js.Opt.get e (fun _ -> assert false) in
  of_opt (Dom_html.document##getElementById (Js.string id))
}}

(* ************************************************************************** *)
(* Display full size images                                                   *)
(* ************************************************************************** *)

{client{

(* get_image_at : int -> image list -> image                                  *)
(* Return the image corresponding to the index                                *)
  let get_image_at id images_list =
    try Some (List.find (fun (idx, _) -> idx = id) images_list)
    with Not_found -> None

(* get_[next|prev]_image : image -> image list -> image                       *)
(* Return the next or prev image corresponding to the given image             *)
  let get_next_image (idx, _) images_list = get_image_at (idx + 1) images_list
  let get_prev_image (idx, _) images_list = get_image_at (idx - 1) images_list

(* fullsize_image : ?string -> Pathname.t -> data ->                          *)
(*                     image list -> image -> div                             *)
(* Return a div hiding all the page to show the image in the path             *)
  let rec fullsize_image ?description:(d="") path data images_list image =
    let description =
      if (String.length d) = 0
      then Pathname.no_extension path
      else d
    and pathlist = Pathname.to_list path
    and close_button = div ~a:[a_class ["close_button"]] [pcdata "X"]
    and left_button =  div ~a:[a_class ["arrow"; "left"]] [pcdata "◄"]
    and right_button =  div ~a:[a_class ["arrow"; "right"]] [pcdata "►"] in
    let next_buttons =
      match (get_prev_image image images_list,
	     get_next_image image images_list) with
	| (None, Some _)   -> [right_button]
	| (Some _, None)   -> [left_button]
	| (Some _, Some _) -> [left_button; right_button]
	| _                -> [] in
    let fullsize_div =
    div ~a:[a_class ["fullsize"]; a_id "fullsize"]
      [div ~a:[a_class ["overlayer"]] [];
       div ~a:[a_class ["box"]]
         [img ~a:[a_class ["image"]] ~alt:description
             ~src:(make_uri ~service:(Eliom_service.static_dir ()) pathlist) ();
          div ~a:[a_class ["details"]]
            ((close_button::next_buttons) @ [pcdata description])]] in
    fullsize_image_handler close_button left_button right_button fullsize_div
      data images_list image;
    fullsize_div

(* append_fullsize_div : data -> image list -> image -> unit                  *)
(* Display the fullsize image at the end of the page                          *)
  and append_fullsize_div data images_list image =
    let filename = snd image in
    let fullsize_div =
      fullsize_image (Pathname.extend_file (full_path data) filename)
	data images_list image in
    Dom.appendChild (Dom_html.document##body)
      (Eliom_content.Html5.To_dom.of_div fullsize_div)

(* fullsize_handler : div -> data -> image -> image list -> unit              *)
(* Event handler which display fullsize image when the thumbnail is clicked   *)
  and fullsize_handler clicked_thumbnail_s data image images_list =
    let clicked_thumbnail = To_dom.of_li clicked_thumbnail_s in
    let append_fullsize_div_ _ = append_fullsize_div data images_list image in
    let open Event_arrows in
        let _ = run (clicks clicked_thumbnail
		       (arr append_fullsize_div_)) () in ()

(* fullsize_image_handler : div -> div -> div -> div -> data -> image list    *)
(*                            -> image -> unit                                *)
(* Events handler for fullsize image actions:                                 *)
(* - When the cross button is clicked, to close the fullsize image            *)
(* - When the escape of the q key is pressed, the fullsize image is closed    *)
(* - When the right and left arrows are pressed, show next/prev image         *)
  and fullsize_image_handler close_button left_button right_button
	fullsize_div data images_list image =
    let remove_div canceller _ =
       Dom.removeChild (Dom_html.document##body) (To_dom.of_div fullsize_div);
       (function None -> () | Some x -> Event_arrows.cancel x) !canceller in
    let display_other_img canceller other_image =
      match other_image with
	| None -> ()
	| Some image ->
	  remove_div canceller ();
	  ignore (append_fullsize_div data images_list image) in
    let display_next c _ = display_other_img c (get_next_image image images_list)
    and display_prev c _ = display_other_img c (get_prev_image image images_list) in
    let handle_key_event c ev =
      match ev##keyCode with
	| 27 (* escape *) | 81 (* q *) -> remove_div c ()
	| 39 (* right *) -> display_next c ()
	| 37 (* left *)  -> display_prev c ()
	| _ -> () in
    let close_button_d = To_dom.of_div close_button
    and left_button_d = To_dom.of_div left_button
    and right_button_d = To_dom.of_div right_button in
    let open Event_arrows in
	let c = ref None in
        c := Some (run (keydowns Dom_html.document (arr (handle_key_event c))) ());
	ignore (run (click close_button_d >>> (arr (remove_div (c)))) ());
	ignore (run (click left_button_d >>> (arr (display_prev (c)))) ());
	ignore (run (click right_button_d >>> (arr (display_next (c)))) ());
	()

}}

{server{

(* Server side call to fullsize_image_handler                                 *)
  let fullsize_image_handler close_button left_button right_button
      fullsize_div data images_list image =
    {unit{ fullsize_image_handler %close_button %left_button %right_button
         %fullsize_div %data %images_list %image }}
}}

(* ************************************************************************** *)
(* Display thumbnails Client Side                                             *)
(* ************************************************************************** *)

{client{

(* display_image_thumbnail : data -> fsv -> image list -> image -> li         *)
(* Return a div containing a thumbnail (on client side)                       *)
  let display_image_thumbnail data fsv images_list image =
    let filename = snd image in
    let file_path = Pathname.extend_file (full_path data) filename in
    let elem = li [show_thumbnail file_path fsv;
		   pcdata (Pathname.no_extension file_path)] in
    let _ = fullsize_handler elem data image images_list in
    elem

}}

(* ************************************************************************** *)
(* Directory browsing                                                         *)
(* ************************************************************************** *)

{client{

(* display_img_client : data -> fsv -> post_coservice' ->                     *)
(*                 (string list, image list) -> ul                            *)
(* Take a list of directories and a list of files and return a div containing *)
(* a pretty displaying of them.                                               *)
  let rec display_img_client data fsv service (dir_list, file_list) =
    let dir_thb_path = Pathname.extend (full_path data) directory_thumbnail in
    let parent () =
      let back_button =
	li ~a:[a_class ["dir"]] [show_img dir_thb_path fsv; pcdata "◄ Back"] in
      let _ = dir_handler_client (chpath data (Pathname.parent (path data))) fsv
	back_button service in back_button in
    let thumbnails_list =
      (List.map
         (fun filename ->
           let thb_button = li ~a:[a_class ["dir"]]
             [show_img dir_thb_path fsv; pcdata filename] in
	   let _ = dir_handler_client
	     (chpath data (Pathname.extend_file (path data) filename)) fsv
             thb_button service in thb_button) dir_list)
      @ (List.map (display_image_thumbnail data fsv file_list) file_list) in
    div ~a:[a_id ("gallery_ct" ^ (single_id data))]
      [p ~a:[a_class ["path"]] [pcdata (Pathname.to_string (path data))];
       ul (if Pathname.is_empty (path data)
	 then thumbnails_list
	 else (parent ())::thumbnails_list)]

(* dir_handler_client : data -> fsv -> li -> post_coservice' -> unit          *)
(* Take the directory button and set the handler associeted with the          *)
(* directory button, so when you click it, it's showing its content.          *)
  and dir_handler_client data fsv clicked_thb service =
    let get_list_from_server () =
      Eliom_client.call_caml_service
        ~service:service () ((Pathname.to_string (original_path data)),
			     (((Pathname.to_string (path data))),
			      (single_id data))) in
    let replace_dir (t, file_lists) _ =
      let gallery_div = get_element_by_id ("gallery" ^ (single_id data))
      and to_replace = get_element_by_id ("gallery_ct" ^ (single_id data))
      and new_div = display_img_client data fsv service file_lists in
      (Dom.replaceChild gallery_div (To_dom.of_div new_div) to_replace) in
    let value_binding _ =
      ignore (Lwt.bind (get_list_from_server ())
                (fun result -> Lwt.return (replace_dir result ()))); () in
    let open Event_arrows in
    let _ = run (click (To_dom.of_li clicked_thb) >>> (arr value_binding)) () in
    ()

}}

{server{

(* dir_handler_server : li -> data -> handler                                 *)
(* Take the directory thumbnail element and return a js action that replace   *)
(* the current directory displaying by the display of the directory clicked   *)
  let dir_handler_server clicked_thb data =
    {unit{ dir_handler_client %data %files_service %clicked_thb
         %client_to_server_service }}

}}

(* ************************************************************************** *)
(* Display thumbnails Server Side                                             *)
(* ************************************************************************** *)

{server{

(* display_directories_thumbnail : Pathname.t -> data -> string -> li         *)
(* On server side, return a thumbnail of a directory                          *)
  let display_directories_thumbnail directory_thumb_path data filename =
    let monli = li ~a:[a_class ["dir"]]
      [show_img directory_thumb_path; pcdata filename] in
    let data = (chpath data (Pathname.extend_file (path data) filename)) in
    ignore {unit{
      Eliom_client.onload
        (fun () ->
           dir_handler_client %data %files_service %monli
             %client_to_server_service)
    }};
    monli

(* display_image_thumbnail : data -> image-> image list -> li                 *)
(* On server side, return a thumbnail of an image                             *)
   let display_image_thumbnail data images_list image =
     let filename = snd image in
     let file_path = Pathname.extend_file (full_path data) filename in
     let elem = li [show_thumbnail file_path;
		    pcdata (Pathname.no_extension file_path)] in
     ignore {unit{
       Eliom_client.onload
         (fun () ->
            fullsize_handler %elem %data %image %images_list)
     }};
     elem

}}

{server{

(* display_img : data -> (string list, image list) -> ul                      *)
(* Take a path and return a list of pictures and directories                  *)
let display_images_server data (dir_list, file_list) =
  let dir_thb_path = Pathname.extend (full_path data) directory_thumbnail in
  div ~a:[a_id ("gallery_ct" ^ (single_id data))]
    [ul ((List.map (display_directories_thumbnail dir_thb_path data) dir_list) @
            (List.map (display_image_thumbnail data file_list) file_list))]

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
     let data = ndata pathname (Pathname.new_path ()) single_id in
     div ~a:[a_class["gallery"]; a_id ("gallery" ^ single_id)]
       [h3 ~a:[a_id "title"] [pcdata title];
        display_images_server data (img_dir_list data)]

   let viewer ?title:(t=default_gallery_title) list_path =
     viewer_path ~title:t
       (Pathname.new_path_of_list list_path)
   and viewer_str ?title:(t=default_gallery_title) str_path =
     viewer_path ~title:t
       (Pathname.new_path_of_string str_path)

}}
