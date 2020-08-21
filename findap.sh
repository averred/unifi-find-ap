#!/bin/bash

# Author: Talha Khan <talha@averred.net>, 21/08/2020

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
        echo "Error: AP $1 not found."
else
        echo "AP MAC: $1"
        echo "Site Name: $(echo $result | cut -d '"' -f8)"
        echo "Site ID: $(echo $result | cut -d '"' -f12)"
fi
