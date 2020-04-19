#!/usr/bin/env bash
export OPTIONS=$*
clear
irb -r ./runners/session.rb --prompt simple
