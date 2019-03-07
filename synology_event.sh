#!/bin/bash
source $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/config
if [ "$synology_notify" == "yes" ]
then
/usr/syno/bin/synonotify DDNSFail "$1"
fi