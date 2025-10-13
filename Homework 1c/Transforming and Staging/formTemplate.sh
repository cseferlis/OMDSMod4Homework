#!/bin/bash

# Set the subscription to 'Azure for Students'
az account set --subscription "Azure for Students"

# Extract the 'id' field using jq from the output of az account show
subId=$(az account show | jq -r '.id')

# If you still want to allow manual entry, you can check if the above command was successful and prompt the user if not.
if [[ -z "$subId" ]]; then
    read -p "Enter subscription id manually: " subId
fi

# Get a 6-character random string
random_string1=$(echo $RANDOM | md5sum | cut -c 1-6)
random_string2=$(echo $RANDOM | md5sum | cut -c 1-6)

# Concatenate "db" with the 6-character random string plus "-mod4db" to create a unique database name
DBNAME="db${random_string1}-mod4db"
DBSERVERNAME="db${random_string2}-mod4server"

# Use double quotes around variable substitutions to ensure any spaces/special characters are handled correctly
sed -i -e "s/@dbName/$DBNAME/g" ./template/parameters.json
sed -i -e "s/@dbServerName/$DBSERVERNAME/g" ./template/parameters.json

echo "Template and parameters created successfully: ./template/template.json and ./template/parameters.json"
