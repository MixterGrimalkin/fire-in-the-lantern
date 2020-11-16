#!/usr/bin/env bash

PI=`./pi.sh`

echo "Uploading F.I.T.L. to ${PI}...."

ssh pi@`cat .pi` mkdir fitl 2>/dev/null
scp -r components pi@`cat .pi`:fitl
scp -r lib pi@`cat .pi`:fitl
scp -r main pi@`cat .pi`:fitl
scp -r media pi@`cat .pi`:fitl
scp -r runners pi@`cat .pi`:fitl
scp scripts/*.sh pi@`cat .pi`:fitl
scp Gemfile* pi@`cat .pi`:fitl

echo "Done"
