#!/usr/bin/env python3

#
# Description: This script retrieves the principal ID for an Azure AD service principal
# given its app display name.

import json
import subprocess
import sys

app_display_name = sys.argv[1]

# Get service principals
service_principals = subprocess.check_output(
    ["az", "ad", "sp", "list", "--all", "--output", "json"]
)
service_principals = json.loads(service_principals)

# Filter service principal by app display name
filtered_sp = None

for sp in service_principals:
    if sp.get("appDisplayName") == app_display_name:
        filtered_sp = sp
        break

# Output the principal ID if found, otherwise print an error message
if filtered_sp:
    principal_id = filtered_sp["id"]
    print(principal_id)
else:
    print(
        'No service principal found with appDisplayName "{}".'.format(
            app_display_name
        )
    )
