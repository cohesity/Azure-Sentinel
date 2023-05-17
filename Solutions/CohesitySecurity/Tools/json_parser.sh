#!/bin/zsh
set -e

# Description: This script reads the configuration from a JSON file (cohesity.json) and generates a time-based UUID if needed.
# It sets variables based on the JSON file contents and generates unique IDs for workspace_name and resource_group if they are not provided.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Global variable to store generated ID
generated_id=""

# Function to generate a time-based UUID if the current_value is empty or null
generate_time_uuid() {
    current_value=$1
    prefix=$2
    max_length=63
    if [[ -z "$current_value" ]]; then
        if [[ -z "$generated_id" ]]; then
            current_timestamp=$(date +%Y%m%d-%H%M%S)
            UUID=$(uuidgen | cut -c1-8) # Truncate UUID to 8 characters
            generated_id="${prefix}-${current_timestamp}-${UUID}"

            # Check if the length of generated_id is more than max_length
            if [[ ${#generated_id} -gt $max_length ]]; then
                echo "Error: Generated ID is too long (${#generated_id} characters). Maximum length allowed is $max_length characters." >&2
                exit 1
            fi
        fi
        echo "$generated_id"
    else
        echo "$current_value"
    fi
}

# Read configuration from cohesity.json
client_id=$(cat ../cohesity.json | jq '."client_id"' | sed 's/^"//g;s/"$//g')
client_key=$(cat ../cohesity.json | jq '."client_key"' | sed 's/^"//g;s/"$//g')
start_days_ago=$(cat ../cohesity.json | jq '."start_days_ago"' | sed 's/^"//g;s/"$//g')
api_key=$(cat ../cohesity.json | jq '."api_key"' | sed 's/^"//g;s/"$//g')
consumer_context=$(cat ../cohesity.json | jq '."consumer_context"' | sed 's/^"//g;s/"$//g')
consumer_fun_prefix=$(cat ../cohesity.json | jq '."consumer_fun_prefix"' | sed 's/^"//g;s/"$//g')
producer_context=$(cat ../cohesity.json | jq '."producer_context"' | sed 's/^"//g;s/"$//g')
producer_fun_prefix=$(cat ../cohesity.json | jq '."producer_fun_prefix"' | sed 's/^"//g;s/"$//g')

# Generate unique IDs for workspace_name and resource_group if not provided
workspace_name=$(cat ../cohesity.json | jq '."workspace_name"' | sed 's/^"//g;s/"$//g')
workspace_name=$(generate_time_uuid "$workspace_name" "automate-test")
resource_group=$(cat ../cohesity.json | jq '."resource_group"' | sed 's/^"//g;s/"$//g')
resource_group=$(generate_time_uuid "$resource_group" "automate-test")

# Read the remaining variables from cohesity.json
user_email=$(cat ../cohesity.json | jq '."user_email"' | sed 's/^"//g;s/"$//g')
container_name=$(cat ../cohesity.json | jq '."container_name"' | sed 's/^"//g;s/"$//g')
location=$(cat ../cohesity.json | jq '."location"' | sed 's/^"//g;s/"$//g')
subscription_id=$(cat ../cohesity.json | jq '."subscription_id"' | sed 's/^"//g;s/"$//g')
object_id=$(cat ../cohesity.json | jq '."object_id"' | sed 's/^"//g;s/"$//g')

cd -
