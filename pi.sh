#!/usr/bin/env bash

if [ ! -f .pi ]
then
    if [ -z "$1" ]
    then
        echo "Specify target IP"
        exit 1
    else
        echo "$1" > .pi
    fi
fi

echo `cat .pi`
