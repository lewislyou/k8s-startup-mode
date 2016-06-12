#/bin/bash

HEAPSTER_GROUP="heapster-option"
function f_addenv(){
cli addenv -k SOURCE -v '"--source=kubernetes:http://${MASTER_IP}:8080?inClusterConfig=false"' -g ${HEAPSTER_GROUP}
cli addenv -k SINK -v '"--sink=zabbix:?zabbix_server=172.16.16.137:10051"' -g ${HEAPSTER_GROUP}
}
function f_delenv(){
cli delenv -k SOURCE  -g ${HEAPSTER_GROUP}
cli delenv -k SINK    -g ${HEAPSTER_GROUP}
}
f_delenv
f_addenv
