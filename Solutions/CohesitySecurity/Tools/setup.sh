#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

source ./json_parser.sh

source ./prerequisite.sh
source ./deploys.sh
source ./config.sh
source ./test.sh
