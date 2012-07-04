(* ************************************************************************** *)
(* Project: Gallery                                                           *)
(* Description: Example of usage of the module Gallery. See gallery.ml        *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/db0company/Gallery         *)
(* ************************************************************************** *)

open Eliom_content
open Html5.D
open Eliom_parameter

module Example_app =
  Eliom_registration.App
    (struct
      let application_name = "gallery"
     end)

let main_service =
  Eliom_service.service
    ~path:[""]
    ~get_params:unit
    ()

let _ = 
  Example_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
	   (head
	      (title (pcdata "Ocsigen Gallery Example")
	      ) [css_link ~uri:(make_uri (Eliom_service.static_dir ())
				  ["css";"style.css"]) ();
		 Gallery.load_css ["css"]])
           (body [h1 [pcdata "Ocsigen Gallery Example"];
		  Gallery.viewer
		    ~title:"My pictures are so pretty"
		    ["images"]
		 ])
	)
    )
