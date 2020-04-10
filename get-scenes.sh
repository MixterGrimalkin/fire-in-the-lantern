#!/usr/bin/env bash

PI=`./pi.sh`

echo "Downloading F.I.T.L. Scene files from ${PI}...."

scp pi@`cat .pi`:fire-lanterns/scenes/* ./app/scenes

echo "Done"


