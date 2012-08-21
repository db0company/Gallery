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
_It will install external modules needed and generate you a configuration file._
* Generate thumbnails by launching the script `./generate_thumbnail.sh gallery_files/images/`
* Compile the example using `make`
* Open the website in your browser

***

### How to insert it in my website?

##### Install files

* Install it by launching the script `./install.sh` _It will install external modules._


You will need these files to add Gallery to your website:
* `gallery.eliom`
* `pathname.eliom`

Copy them (and their interfaces `.eliomi`) in your website source code directory.

* Choose a folder for the images you will want to display.
* Launch the script `./generate_thumbnail.sh` with the folder path you chose.
  _It will generate thumbnails for your images._

* Copy the file `gallery.css` to your gallery folder.

##### Configuration file

* Edit your configuration file to add the two news `.cmo` you will have to insert:

```xml
      <eliom module="/real/path/to/your/sources/folder/pathname.cmo" />
      <eliom module="/real/path/to/your/sources/folder/gallery.cmo">
         <gallery dir="/real/path/to/your/images/folder/" />
      </eliom>
```

* Don't forget to edit these lines with your own paths!

* The gallery directory can be the same as the static directory specified to staticmod ;)

##### Add it on my website code

You will have to call two functions:

* `Gallery.load_css`
  * This function has one parameter: the path of where the css file is.
  * It must be a relative path to the gallery folder specified in the configuration file.
  * The path argument can be a list (`load_css`), a string (`load_css_str`)
    or a [Pathname.t](https://github.com/db0company/Pathname) (`load_css_path`).

* `Gallery.viewer`
  * This function has one optional paramter: the description of the gallery, displayed on top of it.
  * This function has one required parameter: the path of where the images folder is.
  * It must be a relative path to the gallery folder specified in the configuration file.
  * The path argument can be a list (`viewer`), a string (`viewer_str`)
    or a [Pathname.t](https://github.com/db0company/Pathname) (`viewer_path`).

***

### F.A.Q.

##### The colors of the Gallery does not fit with my website

You can modify the gallery style!
Edit the `gallery.css` file with your own colors.

##### My website stop immediatly when I launch it

An exception is thrown when the configuration file is invalid.
Have a look at the [configuration file part](#configuration-file) of this README.

##### Thumbnails are now displaying

Don't forget to launch the `./generate_thumbnail.sh` script to generate them!

If you are sure that they have been generated, check if the folder path you provide in the configuration file is correct (exists, have sufficient permissions, ...).

##### What is Ocsigen and why should I use it for my website?

Ocsigen is a powerful web server and framework in OCaml.

Ocsigen makes possible to write Web applications, client and server side, using OCaml, a very expressive and safe programming language.

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
