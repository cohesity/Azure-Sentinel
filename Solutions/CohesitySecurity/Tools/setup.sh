#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./error_handler.sh
. ./json_parser.sh

. ./prerequisite.sh
error_handler "Failed to complete prerequisites."

. ./deploys.sh
error_handler "Failed to deploy resources."

. ./config.sh
error_handler "Failed to configure resources."

. ./test.sh
error_handler "Failed to run tests."

cd -
