(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Module to display a pretty images gallery for Ocsigen         *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

open HTML5
open Eliom_parameters

(* ************************************************************************** *)
(* General tools                                                              *)
(* ************************************************************************** *)

(* raw_path : string list -> string                                           *)
(* Generate a path string with a list of string.                              *)
(* Example : ["foo"; "bar"] -> "foo/bar/"                                     *)
let raw_path = function
  | h::t -> List.fold_left (fun final_path str -> final_path ^ "/" ^ str) h t
  | []   -> ""

(* extension : string -> string                                               *)
(* Return the extansion of the given filename                                 *)
(* Example : "document.pdf" -> "pdf"                                          *)
let extension filename =
  let start = try (String.rindex filename '.') + 1 with Not_found -> 0
  in try String.sub filename start ((String.length filename) - start)
    with Invalid_argument s -> ""

(* no_extension : string -> string                                            *)
(* Return filename without its extension                                      *)
(* Example : "document.pdf" -> "document"                                     *)
let no_extension filename =
  let size =
    try (String.rindex filename '.') with Not_found -> -1
  in try String.sub filename 0 size with Invalid_argument s -> filename

(* ************************************************************************** *)
(* Images tools                                                               *)
(* ************************************************************************** *)

(* allowed_extension : string list                                            *)
(* Known extensions for images files                                          *)
let allowed_extension = ["JPG";"jpeg";"jpg";"png";"PNG";"gif";"GIF";"BMP";"bmp"]

(* is_img : string -> bool                                                    *)
(* Check if the given filename has a correct extension corresponding to a     *)
(* known image format                                                         *)
let is_img filename =
  let ext = extension filename in
  List.exists
    (fun str -> if (String.compare ext str) == 0 then true else false)
    allowed_extension

(* show_img : string list -> string -> [> `Img ] Eliom_pervasives.HTML5.elt   *)
(* Return an image node corresponding to the given image                      *)
let show_img path description =
  img
    ~alt:description
    ~src:(Eliom_output.Xhtml.make_uri
            ~service:(Eliom_services.static_dir ()) path)
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

(* show_thumbnail : string -> string -> [> `Img ] Eliom_pervasives.HTML5.elt  *)
(* Return an image node corresponding to the thumbnail of the given image     *)
let show_thumbnail path filename =
  show_img (path
            @ [if (Sys.file_exists (raw_path (path@[thumbnail_name filename])))
              then thumbnail_name filename
              else default_thumbnail]) (no_extension filename)

(* ************************************************************************** *)
(* Gallery functions                                                          *)
(* ************************************************************************** *)

(* img_dir_list : string -> (string list * string list)                       *)
(* Browse the given folder name and return two lists :                        *)
(* - The first list contains images filenames                                 *)
(* - The second list contains directories filenames                           *)
let img_dir_list pl =
  let rpath = raw_path pl in
  let no_hidden_file filename = filename.[0] != '.' in
  let rec aux dir acc =
    try
      let file = Unix.readdir dir
      in aux dir (file::acc)
    with End_of_file -> acc
  in let handle = Unix.opendir rpath
     in let filelist = aux handle []
        in (List.filter
              (fun filename ->
                no_hidden_file filename && is_img filename)
              filelist,
            List.filter
              (fun filename ->
                no_hidden_file filename && Sys.is_directory (rpath ^ "/"
                                                             ^ filename))
              filelist
        )

(* viewer : string list -> [> HTML5_types.div ] Eliom_pervasives.HTML5.elt    *)
(* Return a div containing a pretty displaying of a gallery                   *)
let viewer path =
  let flist = (img_dir_list path) in
  div
    ~a:[a_class["hello"]]
    [ul (
	(List.map
           (fun filename ->
             li [show_img (path @ [directory_thumbnail])
		    ("directory : " ^ filename);
		 pcdata (filename)])
           (snd flist)
	)
      @
      (List.map
         (fun filename ->
           li [show_thumbnail path filename;
	       pcdata filename])
         (fst flist)
      )
     )
    ]
 
