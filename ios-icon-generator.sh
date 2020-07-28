#!/usr/bin/env bash
#
# Copyright (C) 2018 smallmuou <smallmuou@163.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

info() {
  local green="\033[1;32m"
  local normal="\033[0m"
  echo -e "[${green}INFO${normal}] $1"
}

error() {
  local red="\033[1;31m"
  local normal="\033[0m"
  echo -e "[${red}ERROR${normal}] $1"
}

warn() {
  local yellow="\033[1;33m"
  local normal="\033[0m"
  echo -e "[${yellow}WARNING${normal}] $1"
}

cmdcheck() {
  if ! command -v $1 &>/dev/null; then
    error "Please install command $1 first." >&2
    exit 1
  fi   
}

#########################################
###           GROBLE DEFINE           ###
#########################################

VERSION=2.1.0
AUTHOR=smallmuou

#########################################
###             ARG PARSER            ###
#########################################

usage() {
  prog=$(basename "$0")
  cat << EOF
$prog version $VERSION by $AUTHOR

USAGE: $prog [OPTIONS] srcfile dstpath

DESCRIPTION:
    This script aim to generate iOS/macOS/watchOS APP icons more easier and simply.

    srcfile - The source png image. Preferably above 1024x1024
    dstpath - The destination path where the icons generate to.

OPTIONS:
    -h      Show this help message and exit
    -n      Name for the generated icons, default is Icon

EXAMPLES:
    $prog 1024.png ~/123

EOF
  exit 1
}

ICON="Icon"

while getopts 'hn:' arg; do
  case $arg in
    h)
      usage
      ;;
    n)
      ICON=$OPTARG
      ;;
    ?)
      # OPTARG
      usage
      ;;
  esac
done

shift $(($OPTIND - 1))

[ $# -ne 2 ] && usage

#########################################
###            MAIN ENTRY             ###
#########################################

cmdcheck sips
src_file=$1
dst_path=$2

# check source file
if ! test -f "$src_file"; then
  error "The source file $src_file does not exist, please check it." >&2
  exit 128
fi

# check width and height 
src_width=$(sips -g pixelWidth $src_file 2>/dev/null | awk '/pixelWidth:/{print $NF}')
src_height=$(sips -g pixelHeight $src_file 2>/dev/null | awk '/pixelHeight:/{print $NF}')

if [ -z "$src_width" ]; then
  error "The source file $src_file is not a image file, please check it." >&2
  exit 128
fi

if (($src_width != $src_height)); then
  warn "The height and width of the source image are different, will cause image deformation."
fi

if grep -q yes <(sips -g hasAlpha "$src_file"); then
  warn "The source image contains an alpha channel, which may cause your app to be rejected.  Use ImageMagick to remove: mogrify -alpha off \"$src_file\""
fi

# create dst directory 
mkdir -p "$dst_path"

# ios sizes refer to https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/app-icon/
# macos sizes refer to https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/
# watchos sizes refer to https://developer.apple.com/design/human-interface-guidelines/watchos/icons-and-images/home-screen-icons/
# 
# 
# name size
sizes_mapper=`cat << EOF
Icon-App-20x20@1x      20
Icon-App-20x20@2x      40
Icon-App-20x20@3x      60
Icon-App-29x29@1x      29
Icon-App-29x29@2x      58
Icon-App-29x29@3x      87
Icon-App-40x40@1x      40
Icon-App-40x40@2x      80
Icon-App-40x40@3x      120
Icon-App-60x60@2x      120
Icon-App-60x60@3x      180
Icon-App-76x76@1x      76
Icon-App-76x76@2x      152
Icon-App-83.5x83.5@2x  167
ItunesArtwork@2x       1024
EOF`

contents_json=`cat << EOF
{
    "images" : [
        {
            "filename" : "Icon-App-20x20@2x.png",
            "idiom" : "iphone",
            "scale" : "2x",
            "size" : "20x20"
        },
        {
            "filename" : "Icon-App-20x20@3x.png",
            "idiom" : "iphone",
            "scale" : "3x",
            "size" : "20x20"
        },
        {
            "filename" : "Icon-App-29x29@1x.png",
            "idiom" : "iphone",
            "scale" : "1x",
            "size" : "29x29"
        },
        {
            "filename" : "Icon-App-29x29@2x.png",
            "idiom" : "iphone",
            "scale" : "2x",
            "size" : "29x29"
        },
        {
            "filename" : "Icon-App-29x29@3x.png",
            "idiom" : "iphone",
            "scale" : "3x",
            "size" : "29x29"
        },
        {
            "filename" : "Icon-App-40x40@2x.png",
            "idiom" : "iphone",
            "scale" : "2x",
            "size" : "40x40"
        },
        {
            "filename" : "Icon-App-40x40@3x.png",
            "idiom" : "iphone",
            "scale" : "3x",
            "size" : "40x40"
        },
        {
            "filename" : "Icon-App-60x60@2x.png",
            "idiom" : "iphone",
            "scale" : "2x",
            "size" : "60x60"
        },
        {
            "filename" : "Icon-App-60x60@3x.png",
            "idiom" : "iphone",
            "scale" : "3x",
            "size" : "60x60"
        },
        {
            "filename" : "Icon-App-20x20@1x.png",
            "idiom" : "ipad",
            "scale" : "1x",
            "size" : "20x20"
        },
        {
            "filename" : "Icon-App-20x20@2x.png",
            "idiom" : "ipad",
            "scale" : "2x",
            "size" : "20x20"
        },
        {
            "filename" : "Icon-App-29x29@1x.png",
            "idiom" : "ipad",
            "scale" : "1x",
            "size" : "29x29"
        },
        {
            "filename" : "Icon-App-29x29@2x.png",
            "idiom" : "ipad",
            "scale" : "2x",
            "size" : "29x29"
        },
        {
            "filename" : "Icon-App-40x40@1x.png",
            "idiom" : "ipad",
            "scale" : "1x",
            "size" : "40x40"
        },
        {
            "filename" : "Icon-App-40x40@2x.png",
            "idiom" : "ipad",
            "scale" : "2x",
            "size" : "40x40"
        },
        {
            "filename" : "Icon-App-76x76@1x.png",
            "idiom" : "ipad",
            "scale" : "1x",
            "size" : "76x76"
        },
        {
            "filename" : "Icon-App-76x76@2x.png",
            "idiom" : "ipad",
            "scale" : "2x",
            "size" : "76x76"
        },
        {
            "filename" : "Icon-App-83.5x83.5@2x.png",
            "idiom" : "ipad",
            "scale" : "2x",
            "size" : "83.5x83.5"
        },
        {
            "filename" : "ItunesArtwork@2x.png",
            "idiom" : "ios-marketing",
            "scale" : "1x",
            "size" : "1024x1024"
        }
    ],
    "info": {
        "author" : "script",
        "version" : 1
    }
}
EOF`

OLD_IFS=$IFS
IFS=$'\n'
srgb_profile='/System/Library/ColorSync/Profiles/sRGB Profile.icc'

for line in $sizes_mapper
do
    name=`echo $line|awk '{print $1}'`
    size=`echo $line|awk '{print $2}'`
    info "Generate $name.png ..."
    if [ -f $srgb_profile ];then
        sips --matchTo $srgb_profile -z $size $size $src_file --out $dst_path/$name.png >/dev/null 2>&1
    else
        sips -z $size $size $src_file --out $dst_path/$name.png >/dev/null
    fi
done

info 'Coping Contents.json ...'
echo "$contents_json" > "$dst_path/Contents.json"

info "Congratulation. All icons for iOS/macOS/watchOS APP are generate to the directory: $dst_path."
