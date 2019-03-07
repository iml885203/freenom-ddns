#!/bin/bash

if [ "$synology_notify" == "yes" ]
then
/usr/syno/bin/synonotify DDNSFail $1
fi