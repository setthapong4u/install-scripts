#!/bin/bash

# Function to URL-encode a string using jq
urlencode() {
    local string="$1"
    # If jq is installed, use it
    if command -v jq &>/dev/null; then
        echo -n "$string" | jq -sRr @uri
    else
        # Fallback: basic encoding (won't cover all cases, best to install jq)
        echo -n "$string" | sed 's/ /%20/g'
    fi
}

# Function to delete a message from the API
delete_message() {
    local message_encoded
    message_encoded=$(urlencode "$1")
    curl -X DELETE -H "Content-Type: application/json" --insecure "$base_url/hello/$message_encoded"
}

# Prompt user for the base URL (default port 5000 for HTTP)
read -p "Enter the base URL (e.g., http://api-s.default.svc.cluster.local): " base_url

# Append port 5000 to the base URL if not already specified
if [[ ! "$base_url" =~ ^http://.*:[0-9]+$ ]]; then
    base_url="http://$base_url:5000"
fi

# Infinite loop to prompt user for input
while true; do
    read -p "Enter a message to delete (or type 'exit' to quit): " user_input

    if [[ "$user_input" == "exit" ]]; then
        break
    fi

    delete_message "$user_input"
done
