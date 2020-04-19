#!/usr/bin/env bash
clear
export EXIT=9
while [ ${EXIT} -eq 9 ]
do
    ruby runners/load.rb $*
    EXIT=$?
done


