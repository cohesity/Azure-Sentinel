#!/bin/zsh

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
