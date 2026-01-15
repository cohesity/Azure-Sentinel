#!/bin/zsh
set -e

# Description: This script first creates a Sentinel resource group using create_sentinel_resource_group.sh,

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./create_sentinel_resource_group.sh

cd -
