Gallery
=======

Gallery is a module for Ocsigen (OCaml Web Server + Framework) to display a cute gallery of images on your website.

<img src="http://public.db0.fr/dev/ocsigen/gallery/gallery0.png" alt="Gallery Screenshot" />

***

### Requirements

* Ocsigen version 2.1 minimum
* ImageMagick

***

### How to test it?

* Install it by launching the script `./install.sh`
_It will install the required external modules and generate a configuration file for you._
* Generate thumbnails by launching the script `./generate_thumbnails.sh gallery_files/images/`
* Compile the example using `make`
* Launch the website using `ocsigenserver -c example.conf`
* Open the website in your browser

***

### How to insert it into my website?

##### Install files

* Install it by launching the script `./install.sh` _It will install external modules._


You will need these files to add Gallery to your website:
* `gallery.eliom`
* `pathname.eliom`
* `.directory.png` (or your own directory thumbnail)

Copy them (and their interfaces `.eliomi`) in your website source code directory.

* Choose a folder for the images you will want to display.
* Launch the script `./generate_thumbnails.sh` with the folder path you chose.
  _It will generate thumbnails for your images._

* Copy the file `gallery.css` to your gallery folder.

##### Configuration file

* Edit your configuration file to add the two news `.cmo` you will have to insert:

```xml
      <eliom module="/real/path/to/your/sources/folder/_server/pathname.cmo" />
      <eliom module="/real/path/to/your/sources/folder/_server/gallery.cmo">
         <gallery dir="/real/path/to/the/gallery/folder/" />
      </eliom>
```

* Don't forget to edit these lines with your own paths!

* The gallery directory can be the same as the static directory specified to staticmod ;)

##### Add it to my website code

* Add `pathname.eliom` and `gallery.eliom` in your Makefile, both on the server and client sides.

You will have to call two functions:

* `Gallery.load_css`
  * This function has one parameter: the path of the css file.
  * It must be a _relative path_ to the gallery folder specified in the configuration file.
  * The path argument can be a list (`load_css`), a string (`load_css_str`)
    or a [Pathname.t](https://github.com/db0company/Pathname) (`load_css_path`).
  * This function returns an HTML5 element that must be added in the `head` list:

```ocaml
       (html
           (head (title (pcdata "Ocsigen Gallery Example")) [Gallery.load_css ["css"]])
           ...)
```

* `Gallery.viewer`
  * This function has one optional paramter: the description of the gallery, displayed on top of it.
  * This function has one required parameter: the path of the images folder.
  * It must be a _relative path_ to the gallery folder specified in the configuration file.
  * The path argument can be a list (`viewer`), a string (`viewer_str`)
    or a [Pathname.t](https://github.com/db0company/Pathname) (`viewer_path`).
  * This function return an HTML5 div element that can be added on your website,
    anywhere that its possible to add a div element :)
  * You can have as many gallery as you want on the same page!

***

### F.A.Q.

##### The colors of the Gallery does not fit with my website

You can modify the gallery style!
Edit the `gallery.css` file with your own colors.

##### My website stops immediatly when I launch it

An exception is thrown when the configuration file is invalid.
Have a look at the [configuration file part](#configuration-file) of this README.

##### Thumbnails are not being displayed

Don't forget to launch the `./generate_thumbnails.sh` script to generate them!

If you are sure that they have been generated, check if the folder path you provide in the configuration file is correct (exists, has sufficient permissions, ...).

##### Unbound module Gallery

In OCaml and Ocsigen, file order is important. So, in your Makefile and in your configuration file, don't forget to put pathname before gallery, and gallery before the file which is calling gallery functions!

##### What is Ocsigen and why should I use it for my website?

Ocsigen is a powerful web server and framework written in OCaml.

Ocsigen makes it possible to write Web applications, client and server side, using OCaml, a very expressive and safe programming language.

* Same language and libraries for client and server parts
* No need to encode data before sending it
* Use server-side values in your client code!
* Call server-side functions from the browser!
* Handle server-to-client communications transparently!
* Keep your client side program running when you change page!

More information: [Official Website](http://ocsigen.org/)

##### More screenshots, please!

<img src="http://public.db0.fr/dev/ocsigen/gallery/gallery1.png" alt="Gallery Screenshot" />
<img src="http://public.db0.fr/dev/ocsigen/gallery/gallery3.png" alt="Gallery Screenshot" />
<img src="http://public.db0.fr/dev/ocsigen/gallery/gallery2.png" alt="Gallery Screenshot" />


***


## Copyright/License

     Copyright 2012 Barbara Lepage
  
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
  
         http://www.apache.org/licenses/LICENSE-2.0
  
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.


### Author

* Made by __db0__
* Website: http://db0.fr/
* Contact: db0company@gmail.com


### Up to date

Latest version of this project is on GitHub:
* https://github.com/db0company/Gallery
