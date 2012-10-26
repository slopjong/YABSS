#!/bin/bash

# prerequisites:
#
#  - the sliced images are prefixed with impress
#  - the sliced images are in the same directory as the html file generated by gimp or other slice tools  

[ $# -lt 1 ] && { echo "You must provide the html file which contains the sliced images."; exit; }
[ $# -gt 1 ] && echo "The second argument will be ommitted.";
[ -f $1 ] || { echo "The file '$1' doesn't exist"; exit 1; }

_path=$(dirname $1)
_html=$(basename $1)

cd ${_path}

for image in $(egrep -o "impress.+png" ${_html}); 
do 
	converted=$(base64 $image);
	converted=$(echo $converted | sed 's/\//\\\//g')
	sed -i "s/${image}/data:image\/png;base64,${converted}/g" ${_html}
done

cd -