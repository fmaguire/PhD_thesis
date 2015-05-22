#!/bin/bash

for file in "$@"
do
    base=${file%.svg}
    echo "Converting" $file
    inkscape -D $file -A $base.pdf
    echo "Done"
    echo "*****"
done
