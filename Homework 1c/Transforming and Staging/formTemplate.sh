#!/bin/bash

# Get a 6-character random string
random_string1=$(echo $RANDOM | md5sum | cut -c 1-6)
random_string2=$(echo $RANDOM | md5sum | cut -c 1-6)

# Concatenate "db" with the 6-character random string plus "-DS310db" to create a unique database name
DBNAME="db${random_string1}-DS310db"
DBSERVERNAME="db${random_string2}-ds310server"

# Use double quotes around variable substitutions to ensure any spaces/special characters are handled correctly
sed -i -e "s/@dbName/$DBNAME/g" ./template/parameters.json
sed -i -e "s/@dbServerName/$DBSERVERNAME/g" ./template/parameters.json

echo "Template and parameters created successfully: ./template/template.json and ./template/parameters.json"