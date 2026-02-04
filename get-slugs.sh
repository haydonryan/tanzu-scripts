#!/bin/bash

# Script to fetch VMware Tanzu Network products and display slug/name in two columns
# Usage: ./get-slugs.sh

set -e

API_URL="https://network.tanzu.vmware.com/api/v2/products"

echo "Fetching VMware Tanzu Network products..."
echo ""

# Function to parse JSON using Python (usually available)
parse_with_python() {
    python3 -c "
import json
import sys

data = json.load(sys.stdin)

# Handle different response structures
if isinstance(data, dict) and 'products' in data:
    products = data['products']
elif isinstance(data, list):
    products = data
else:
    products = []

# Print header
print(f'{'SLUG':<40} NAME')
print('-' * 80)

# Print products
for product in products:
    if isinstance(product, dict):
        slug = product.get('slug', 'N/A')
        name = product.get('name', 'N/A')
        print(f'{slug:<40} {name}')
"
}

# Function to parse JSON using jq
parse_with_jq() {
    jq -r '
    if type == "object" and has("products") then
        .products[]
    elif type == "array" then
        .[]
    else
        empty
    end |
    select(.slug != null and .name != null) |
    [.slug, .name] |
    @tsv
    ' | column -t -s $'\t' -N "SLUG,NAME"
}

# Fetch and parse
curl -s "$API_URL" | parse_with_python


