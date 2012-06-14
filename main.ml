(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Example of usage of the module Gallery. See gallery.ml        *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

open Eliom_content
open Html5.D
open Eliom_parameter

let main_service =
  Eliom_service.service
    ~path:[""]
    ~get_params:unit
    ()

let _ = 
  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
	   (head
	      (title (pcdata "Ocsigen Gallery Example")
	      ) [Gallery.load_css ["css";"gallery.css"]])
           (body [h1 [pcdata "Ocsigen Gallery Example"];
		  Gallery.viewer ["images"]
		 ])
	)
    )
