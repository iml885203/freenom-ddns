#!/bin/bash
GET_IP_URL="https://api.ipify.org/"
UPDATE_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/update.sh
LOGGER_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/log.sh
source $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/config

DNS_IP="$(nslookup $freenom_domain_name 80.80.80.80 | tail -2 | head -1 | awk '{print $2}')"
CURR_IP="$(curl -s $GET_IP_URL)"

$LOGGER_SCRIPT start

$LOGGER_SCRIPT continue "Current IP: $CURR_IP :: DNS IP: $DNS_IP"

if [ "$DNS_IP" == "$CURR_IP" ]
then
$LOGGER_SCRIPT continue "No change is needed, exiting"
else
$LOGGER_SCRIPT continue "Change is needed procedeing to execute freenom update script"
$UPDATE_SCRIPT
fi
$LOGGER_SCRIPT end