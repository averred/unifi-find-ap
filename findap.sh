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

# Find AP
SITE_OBJID=$(mongo --quiet --port 27117 --eval 'db.getSiblingDB("ace").getCollection("device").find({"mac":"'"$1"'"}).forEach(function(document){print(document.site_id)})')

if [[ -z $SITE_OBJID ]]
then
        echo -e "Error: AP MAC $1 not found in UniFi database."
        exit 1
fi

SITE_NAME=$(mongo --quiet --port 27117 --eval 'db.getSiblingDB("ace").getCollection("site").find({"_id":ObjectId("'"${SITE_OBJID}"'")}).forEach(function(document){print(document.desc)})')
SITE_ID=$(mongo --quiet --port 27117 --eval 'db.getSiblingDB("ace").getCollection("site").find({"_id":ObjectId("'"${SITE_OBJID}"'")}).forEach(function(document){print(document.name)})')

if [[ -z $SITE_NAME ]] || [[ -z $SITE_ID ]]
then
        echo "Error: AP found but unable to retrieve site information from UniFi database."
        exit 1
fi

DOMAIN=$(mongo --quiet --port 27117 --eval 'db.getSiblingDB("ace").setting.find({"key":"super_identity"}).forEach(function(document){print(document.hostname)})')
URL="https://$DOMAIN:8443/manage/site/$SITE_ID/devices/list/1/100"
echo "AP MAC: $1"
echo "Site Name: $SITE_NAME"
echo "Site ID: $SITE_ID"
echo "Site URL: $URL"
