open HTML5
open Eliom_parameters

let img_list_from_directory path =
  let rec aux dir acc =
    try
      let file = Unix.readdir dir
      in aux dir (file::acc)
    with End_of_file -> acc
  in let handle = Unix.opendir path
     in let filelist = aux handle []
	in List.filter (fun filename -> filename.[0] != '.') filelist

let viewer path =
  div
    ~a:[a_class["hello"]]
    [ul (List.map
           (fun filename ->
	     li [pcdata filename]
	   )
	(img_list_from_directory path))
    ]
