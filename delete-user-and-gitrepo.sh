#!/bin/bash
# must run as root

username=$1
subdomain=$2

echo "Deleting user: $username"
/usr/sbin/userdel -r $username &&

echo "Removing subdomain: $subdomain"
cd /usr/local/psa/bin/ &&
./subdomain --remove -subdomains $subdomain -domain cl-sf.com
