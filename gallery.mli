
open Eliom_content
open Html5.D
open Eliom_parameter

val viewer : string list -> [> Html5_types.div ] Eliom_content.Html5.D.elt
val viewer_str : string -> [> Html5_types.div ] Eliom_content.Html5.D.elt

val load_css : string list -> [> Html5_types.link ] Eliom_content_core.Html5.elt

