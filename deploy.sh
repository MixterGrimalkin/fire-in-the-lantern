#!/usr/bin/env bash

PI=`./pi.sh`

echo "Uploading F.I.T.L. to ${PI}...."

ssh pi@`cat .pi` mkdir fire-lanterns 2>/dev/null
scp -r app/* pi@`cat .pi`:fire-lanterns

echo "Done"
