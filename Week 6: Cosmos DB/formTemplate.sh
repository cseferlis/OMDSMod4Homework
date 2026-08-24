#!/usr/bin/env bash
set -euo pipefail

# Get a 6-character random string for a unique Cosmos DB account name.
random_string=$(echo "$RANDOM" | md5sum | cut -c 1-6)

# Cosmos DB account names must be globally unique.
CDBNAME="cosmosdb${random_string}"

# Replace the placeholder in the parameters file with the generated Cosmos DB account name.
# The region is not replaced here because template.json now defaults to the resource group's region.
sed -i.bak -e "s/@dbName/${CDBNAME}/g" ./template/parameters.json
rm -f ./template/parameters.json.bak

echo "Cosmos DB account name set to: ${CDBNAME}"
echo "Template and parameters are ready: ./template/template.json and ./template/parameters.json"
