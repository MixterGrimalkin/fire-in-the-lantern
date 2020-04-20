#!/usr/bin/env bash

PI=`./pi.sh`

echo "Uploading F.I.T.L. to ${PI}...."

ssh pi@`cat .pi` mkdir fitl 2>/dev/null
scp -r fitl/* pi@`cat .pi`:fitl

echo "Done"
