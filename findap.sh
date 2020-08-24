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
SITE_ID=$(mongo ace --port 27117 --quiet <<EOF | grep site_id | cut -d '"' -f4
        db.device.find({"mac":"$1"}, {}).pretty()
EOF
)
echo $SITE_ID
}


findSiteName() {
SITE_NAME=$(mongo ace --port 27117 --quiet <<EOF
        db.site.find({"_id":ObjectId("$1")}, {}).pretty()
EOF
)
echo $SITE_NAME
}

RESULT=$(findSiteName $(findSiteId $1))

if [[ $RESULT == *"Error: invalid object id: length"* ]]
then
        echo "Error: AP MAC $1 not found in UniFi database."
else
        SITE_NAME=$(echo $RESULT | cut -d '"' -f8)
        SITE_ID=$(echo $RESULT | cut -d '"' -f12)
        DOMAIN=$(mongo --quiet --port 27117 --eval 'db.getSiblingDB("ace").setting.find({"key": "super_identity"}).forEach(function(document){ print(document.hostname) })')
        URL="https://$DOMAIN:8443/manage/site/$SITE_ID/devices/list/1/100"
        echo "AP MAC: $1"
        echo "Site Name: $SITE_NAME"
        echo "Site ID: $SITE_ID"
        echo "Site URL: $URL"
fi
