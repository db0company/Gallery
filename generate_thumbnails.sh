#!/bin/bash
## ########################################################################## ##
## Project: Gallery                                                           ##
## Description: Script to generate thumbnails for images displayed in Gallery ##
## Author: db0 (db0company@gmail.com, http://db0.fr/)                         ##
## Latest Version is on GitHub: https://github.com/db0company/Gallery         ##
## ########################################################################## ##

## ########################################################################## ##
## Is ImageMagick installed?                                                  ##
## ########################################################################## ##

type mogrify > /dev/null
if [ $? -ne 0 ]
then
    echo >&2 "ImageMagick is not installed!"
    exit 1
fi

## ########################################################################## ##
## Command line arguments checking                                            ##
## ########################################################################## ##

function usage() {
    echo >&2 "usage: $0 images_directory [directory_thumbnail || --clean]";
}

if [ $# -lt 1 ]||[ $# -gt 2 ]
then
    usage
    exit 1
fi

if [ ! -d $1 ]
then
    echo "$1: No such file or directory."
    exit 2
fi

## ########################################################################## ##
## Directory thumbnail checking                                               ##
## ########################################################################## ##

if [ $# -eq 2 ]&&[ $2 != '--clean' ]
then
    directory_thumbnail=`pwd`'/'$2
else
    directory_thumbnail=`pwd`'/.directory.png'
fi

if [ ! -f $directory_thumbnail ]
then
    echo "Directory thumbnail \"$directory_thumbnail\", no such file."
    exit 2
fi

## ########################################################################## ##
## Clean directory: Remove thumbnails!                                        ##
## ########################################################################## ##

# This function remove all the thumbnails previously generated                ##
function	clean() {
    echo "Deleting thumbnails..." && \
	find $1 -name ".thb_*" -print -and -delete && \
	find $1 -name '.directory.png' -print -and -delete && \
	echo "Done."
}

if [ $# -eq 2 ]&&[ $2 = '--clean' ]
then
    clean $1
    exit 0
fi

## ########################################################################## ##
## Generate thumbnails                                                        ##
## ########################################################################## ##

mogrify -resize 100x100 $directory_thumbnail || exit 1

# Array of string containing allowed extensions for images files              ##
declare -a allowed_extension=("jpeg" "jpg" "png" "gif" "bmp")

# generate_thumbnail take a string filename, check if it's an image using the ##
# extension and generate a thumbnail for this image using imagemagick         ##
function generate_thumbnail() {
    filename=$1
    if [ $filename = '*' ]
    then return;
    fi
    for i in ${!allowed_extension[*]}
    do
	if [ ${filename##*.} = ${allowed_extension[i]} ]
	then
	    echo -n "file $filename, conversion..."
	    thb=".thb_$filename"
	    cp $filename $thb && \
		mogrify -resize 100x100 $thb && \
		echo "Done."
	    return;
	fi
    done
    echo "file $filename, extension not allowed"
}

## generate_thumbnails browse the current directory and all subdirectories    ##
## and call generate_thumbnail for each files                                 ##
function generate_thumbnails() {
    echo -n "Copy directory thumbnail.." && \
	cp $directory_thumbnail '.directory.png' && \
	echo "Done."
    for d in *; do
    if [ -d $d ]
    then
	cd $d
	generate_thumbnails
	cd ..
    else
	generate_thumbnail $d
    fi
  done
}

## Call generate_thumbnails with the given directory                          ##
cd $1
if [ $? -eq 0 ]
then generate_thumbnails
else exit 2
fi

## Program terminated in success                                              ##
exit 0
