#!/bin/zsh
#
# Description: This script performs a series of deployment steps.
# It first removes existing resources, deploys configurations, and
# can optionally deploy producer and consumer functions.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Load JSON parser
. ../../json_parser.sh

# Source error handling script
. ./error_handling.sh

# Remove existing resources
./remove.py || error_handler

# Deploy configurations
. ./deploy_config.sh || error_handler

# Uncomment the following lines to deploy producer and consumer functions
# ./deploy.py "$producer_fun_prefix" "./$producer_context/" || error_handler
# ./deploy.py "$consumer_fun_prefix" "./$consumer_context/" || error_handler
