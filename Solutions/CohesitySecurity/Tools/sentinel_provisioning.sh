#!/bin/zsh

# Description: This script is responsible for running the Azure Sentinel provisioning process.
# It sources and executes other scripts for prerequisites, deployment, configuration, and testing,
# while also handling errors during each step.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./error_handler.sh
. ./json_parser.sh

. ./prerequisite.sh
error_handler "Failed to complete prerequisites."

. ./deploy_solution.sh
error_handler "Failed to deploy resources."

. ./config.sh
error_handler "Failed to configure resources."

. ./test.sh
error_handler "Failed to run tests."

cd -
