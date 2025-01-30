#!/bin/bash

# Extract the 'id' field using jq from the output of `az account show`
subId=$(az account show | jq -r '.id')

# If you still want to allow manual entry, you can check if the above command was successful
# and prompt the user if not.
if [[ -z "$subId" ]]; then
    read -p "Enter subscription id manually: " subId
fi

# Get a 6-character random string
random_string=$(echo $RANDOM | md5sum | cut -c 1-6)

# Concatenate "datafactory" with the 6-character random string
DFNAME="datafactory${random_string}"


# Use double quotes around variable substitutions to ensure any spaces/special characters are handled correctly
sed -i -e "s/@dfName/$DFNAME/g" ./template/parameters.json
sed -i -e "s/@subId/$subId/g" ./template/parameters.json

echo "Template and parameters created successfully: ./template/template.json and ./template/parameters.json"
