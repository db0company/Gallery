(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Example of usage of the module Gallery. See gallery.ml        *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

open HTML5
open Eliom_parameters

let main_service =
  Eliom_services.service
    ~path:[""]
    ~get_params:unit
    ()

let _ = 
  Eliom_output.Html5.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
	   (head
	      (title (pcdata "Ocsigen Gallery Example")
	      ) [])
           (body [h1 [pcdata "Hello World!"];
		  Gallery.viewer ["images"]
		 ])
	)
    )
