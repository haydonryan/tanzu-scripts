#!/bin/bash

# Script to fetch available versions for a VMware Tanzu Network product
# Usage: ./get-product-versions.sh <slug>
# Example: ./get-product-versions.sh build-service

set -e

# Check if slug parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: No slug provided."
    echo ""
    echo "Usage: $0 <slug>"
    echo "Example: $0 build-service"
    echo ""
    echo "To see available products, run: ./tanzu-products.sh"
    exit 1
fi

SLUG="$1"
API_URL="https://network.tanzu.vmware.com/api/v2/products/${SLUG}/releases"

echo "Fetching versions for: $SLUG"
echo ""

# Function to parse JSON using Python
parse_with_python() {
    python3 -c "
import json
import sys

data = json.load(sys.stdin)

# Handle different response structures
if isinstance(data, dict) and 'releases' in data:
    releases = data['releases']
elif isinstance(data, list):
    releases = data
else:
    releases = []

if not releases:
    print('No versions found for this product.')
    sys.exit(0)

# Print header
print(f'{'VERSION':<30} {'RELEASE DATE':<20} STATUS')
print('-' * 70)

# Print releases
for release in releases:
    if isinstance(release, dict):
        version = release.get('version', 'N/A')
        release_date = release.get('release_date', release.get('releaseDate', 'N/A'))
        status = release.get('status', 'N/A')

        # Truncate version if too long
        version_display = version[:28] if len(version) > 28 else version

        print(f'{version_display:<30} {release_date:<20} {status}')
"
}

# Fetch and parse
curl -s "$API_URL" | parse_with_python

echo ""
echo "Done!"
