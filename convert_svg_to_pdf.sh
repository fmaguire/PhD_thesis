#!/bin/bash

for file in "$@"
do
    s=${file##*/}
    base=${s%.svg}
    echo "Converting" $file
    inkscape -D $file -A $base.pdf
    echo "Done"
    echo "*****"
done
