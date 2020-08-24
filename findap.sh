#!/bin/bash

# Author: Talha Khan <tkhan@5gcomms.com>, 24/08/2020

# Usage helper function
display_usage() {
        echo "This script searches the UniFi AP by MAC address and returns site information."
        echo "The MAC address must be supplied in colon-hexadecimal notation (01:23:45:67:78:9a)."
        echo -e "Usage: $0 <UniFi AP MAC>\n"
}

# Display usage and exit if no parameters supplied
if [[ -z $1 ]]
then
        echo -e "Error: No MAC address supplied.\n"
        display_usage
        exit 1
fi

# Display usage and exit if help requested
if [[ ( $1 == "-h" ) || ( $1 == "--help" ) ]]
then
        display_usage
        exit 0
fi

# Validate MAC address supplied
if ! [[ `echo $1 | egrep "^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$"` ]]
then
        echo -e "Error: Invalid MAC address.\n"
        display_usage
        exit 1
fi

findSiteId() {
site_id=$(mongo ace --port 27117 --quiet <<EOF | grep site_id | cut -d '"' -f4
        db.device.find({"mac":"$1"}, {}).pretty()
EOF
)
echo $site_id
}


findSiteName() {
site_name=$(mongo ace --port 27117 --quiet <<EOF
        db.site.find({"_id":ObjectId("$1")}, {}).pretty()
EOF
)
echo $site_name
}

result=$(findSiteName $(findSiteId $1))

if [[ $result == *"Error: invalid object id: length"* ]]
then
        echo "Error: AP MAC $1 not found in UniFi database."
else
        echo "AP MAC: $1"
        echo "Site Name: $(echo $result | cut -d '"' -f8)"
        echo "Site ID: $(echo $result | cut -d '"' -f12)"
fi
