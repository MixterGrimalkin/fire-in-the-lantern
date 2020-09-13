#!/usr/bin/env bash
export OPTIONS=$*
export RUBYOPT='-W0'
clear
irb -r ./runners/session.rb --prompt simple
