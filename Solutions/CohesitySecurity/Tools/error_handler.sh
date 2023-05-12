#!/bin/zsh

# Description: This script defines an error handler function that takes an error message as an argument.
# If an error occurs during script execution, the script will print the provided error message and exit with an error status.

error_handler() {
    local error_message="$1"
    if [ -z "$error_message" ]; then
        error_message="An error occurred in script execution. Exiting."
    fi

    if [ $? -ne 0 ]; then
        echo "$error_message"
        exit 1
    fi
}
