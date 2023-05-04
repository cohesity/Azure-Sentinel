# error_handling.sh

# Exit on error
set -e

# Error handling function
error_handler() {
    local error_message="$1"

    if [ -z "$error_message" ]; then
        error_message="An error occurred during the execution of the script. Exiting."
    fi

    echo "$error_message"
    exit 1
}
