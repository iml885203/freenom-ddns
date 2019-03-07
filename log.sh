#!/bin/bash
FULL_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/log.log
if [ ! -e $FULL_PATH ]
then
touch $FULL_PATH
fi
case $1 in
"erase")
rm $FULL_PATH
;;
"start")
echo "------- Started domain address check at: $(date) -------" >> $FULL_PATH
;;
continue)
echo $2 >> $FULL_PATH
;;
"end")
echo "" >> $FULL_PATH
;;
*)
echo "$1  no es una opción"
exit 1
;;
esac