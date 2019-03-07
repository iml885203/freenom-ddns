#!/bin/bash
set -u

# settings
# Login information of freenom.com
# Open DNS management page in your browser.
# URL vs settings:
#   https://my.freenom.com/clientarea.php?managedns={freenom_domain_name}&domainid={freenom_domain_id}
source $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/config
BASE_URL="https://my.freenom.com"
CAREA_URL="$BASE_URL/clientarea.php"
LOGIN_URL="$BASE_URL/dologin.php"
LOGOUT_URL="$BASE_URL/logout.php"
MANAGED_URL="$CAREA_URL?managedns=$freenom_domain_name&domainid=$freenom_domain_id"
GET_IP_URL="https://api.ipify.org/"
LOGGER_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/log.sh

# get current ip address
current_ip="$(curl -s "$GET_IP_URL")"

if [ -z "$current_ip" ]; then
    $LOGGER_SCRIPT continue "Could not get current IP address."
    /usr/syno/bin/synonotify DDNSFail "{'%DDNS_HOST_NAME%':'$freenom_domain_name','%EXTERNAL_IP%':'$current_ip','%DDNS_NAME%':'freenom','%FAIL_REASON%':'Could not get current IP address.'}"
    exit 1
fi

cookie_file=$(mktemp)
cleanup() {
    $LOGGER_SCRIPT continue "Cleanup"
    rm -f "$cookie_file"
}
trap cleanup INT EXIT TERM

$LOGGER_SCRIPT continue "Login"
loginResultUrl=$(curl --compressed -kLs -o /dev/null -c "$cookie_file" \
                   -F "username=$freenom_email" -F "password=$freenom_passwd" \
                   -e "$CAREA_URL" \
                   -w %{url_effective} \
                   "$LOGIN_URL" 2>&1)

if [ ! -s "$cookie_file" ]; then
    $LOGGER_SCRIPT continue "Login failed: empty cookie."
    /usr/syno/bin/synonotify DDNSFail "{'%DDNS_HOST_NAME%':'$freenom_domain_name','%EXTERNAL_IP%':'$current_ip','%DDNS_NAME%':'freenom','%FAIL_REASON%':'Login failed: empty cookie.'}"
    exit 1
fi

if echo "$loginResultUrl" | grep "/clientarea.php?incorrect=true"; then
    $LOGGER_SCRIPT continue "Login failed."
    /usr/syno/bin/synonotify DDNSFail "{'%DDNS_HOST_NAME%':'$freenom_domain_name','%EXTERNAL_IP%':'$current_ip','%DDNS_NAME%':'freenom','%FAIL_REASON%':'Login failed.'}"
    exit 1
fi

$LOGGER_SCRIPT continue "Update $current_ip to domain($freenom_domain_name)"
updateResult=$(curl --compressed -k -L -b "$cookie_file" \
                    -e "$MANAGED_URL" \
                    -F "dnsaction=modify" \
                    -F "records[0][line]=" \
                    -F "records[0][type]=A" \
                    -F "records[0][name]=" \
                    -F "records[0][ttl]=14440" \
                    -F "records[0][value]=$current_ip" \
                    "$MANAGED_URL" 2>&1)

if ! echo "$updateResult" | grep -q "name=\"records\[0\]\[value\]\" value=\"$current_ip\""; then
    $LOGGER_SCRIPT continue "Update failed." 1>&2
    /usr/syno/bin/synonotify DDNSFail "{'%DDNS_HOST_NAME%':'$freenom_domain_name','%EXTERNAL_IP%':'$current_ip','%DDNS_NAME%':'freenom','%FAIL_REASON%':'Update failed.'}"
    exit 1
fi

$LOGGER_SCRIPT continue "Logout"
curl --compressed -k -b "$cookie_file" "$LOGOUT_URL" > /dev/null 2>&1

exit 0