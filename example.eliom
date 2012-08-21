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

let page_title () = h1 [pcdata "Ocsigen Gallery Example"]

let page_menu () =
  ul ~a:[a_class ["menu"]]
    [li [a (~service:main_service) [pcdata "Lorem ipsum"] ()];
     li [a (~service:main_service) [pcdata "Dolor sit amet"] ()];
     li [a (~service:main_service) [pcdata "Consectetur"] ()];
     li [a (~service:main_service) [pcdata "Adipiscing elit"] ()];
     li [a (~service:main_service) [pcdata "Vivamus"] ()];
     li [a (~service:main_service) [pcdata "Congue ligula"] ()];
     li [a (~service:main_service) [pcdata "In velit aliquam"] ()];
     li [a (~service:main_service) [pcdata "Et dignissim"] ()];
     li [a (~service:main_service) [pcdata "Erat congue"] ()]
    ]

let page_content_1 () =
  div
    [h3 [pcdata "Ut elit ante, pulvinar sed"];
     p [pcdata "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur at risus at purus pellentesque tincidunt. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt elementum odio id pellentesque. Etiam pretium ipsum in turpis egestas in consectetur tortor porttitor. Aliquam ac vestibulum lectus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent vitae odio odio. Nulla auctor velit vitae odio aliquam consectetur. Curabitur est quam, sodales id sagittis non, malesuada et eros. Aenean fermentum faucibus dui nec ornare. Integer non odio ac libero tempor porttitor. Nulla facilisi. Phasellus tincidunt pretium fermentum. Nullam quis leo quis dolor lacinia sollicitudin vel facilisis lectus. Nam sem magna, porttitor sit amet adipiscing nec, luctus nec lectus."];
    ]

let page_content_2 () =
  div
     [h3 [pcdata "Sed porttitor sagittis etiam"];
      p [pcdata "Donec sit amet nunc vitae magna congue porta. Praesent convallis augue at est pharetra vel consectetur enim interdum. Cras erat dui, commodo quis malesuada sed, mattis at ante. Donec aliquet, velit dignissim porta volutpat, ligula orci vestibulum mauris, in egestas nibh lectus nec eros. Fusce vitae dolor magna, porttitor mattis est. Integer libero tortor, ultrices sit amet vehicula at, accumsan sit amet neque. Fusce nec diam quis urna faucibus aliquam quis scelerisque magna."]
     ]

let _ = 
  Example_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
	   (head
	      (title (pcdata "Ocsigen Gallery Example"))
	      [css_link ~uri:(make_uri (Eliom_service.static_dir ()) ["style.css"]) ();
		 Gallery.load_css ["css"]])
           (body [page_title ();
		  page_menu ();
		  div ~a:[a_class ["page"]]
		  [page_content_1 ();
		   Gallery.viewer ~title:"My pictures are so pretty" ["images"];
		   page_content_1 ();
		   Gallery.viewer ["images";"funny"];
		   page_content_2 ()]
		 ])
	)
    )
