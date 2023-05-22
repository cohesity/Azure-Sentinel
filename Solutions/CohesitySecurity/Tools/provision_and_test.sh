#!/bin/zsh
set -e

# Description: This script is responsible for running the Azure Sentinel provisioning process.
# It sources and executes other scripts for prerequisites, deployment, configuration, and testing,
# while also handling errors during each step.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./json_parser.sh

. ./prerequisite.sh

. ./deploy_solution.sh

. ./config.sh

. ./test.sh

cd -
