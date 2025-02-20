#!/bin/bash
# Get a 6-character random string
random_string1=$(echo $RANDOM | md5sum | cut -c 1-6)

# Concatenate "db" with the 6-character random string plus "-omdsmod4db" to create a unique database name
CDBNAME="cosmosdb${random_string1}"

# Use double quotes around variable substitutions to ensure any spaces/special characters are handled correctly
sed -i -e "s/@dbName/$CDBNAME/g" ./template/parameters.json

echo "Template and parameters created successfully: ./template/template.json and ./template/parameters.json"