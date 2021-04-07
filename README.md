# unifi-find-ap

## Summary
Bash script to find UniFi AP by MAC address by accessing MongoDB

This script searches the UniFi AP by MAC address and returns site information.
The MAC address must be supplied in colon-hexadecimal notation (01:23:45:67:78:9a).

### Why?
Ever adopted a UniFi AP to a site and forgotten which site it's on? UniFi does not currently have an easy way to figure this out. 

It would be handy if UniFi had a global search box that allowed you to search by MAC address but it doesn't... so this is my solution to solve the support desk woes.

## Usage
    $ unifi-find-ap <UniFi AP MAC>
