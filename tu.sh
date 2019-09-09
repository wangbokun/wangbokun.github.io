#!/bin/bash

for i in `ls assets/img`; do

    ctx=`grep $i * -r`

    if [ ! $ctx ]; then
        echo $i $ctx
    else
        echo "======================="
    fi
done
