#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./json_parser.sh

az monitor log-analytics workspace create \
    -g "$resourcegroup" \
    -n "$workspacename"
