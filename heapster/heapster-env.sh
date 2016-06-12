#/bin/bash

HEAPSTER_GROUP="heapster-option"

function f_addenv(){
#cli addenv -k MASTER_IP -v '""' -g ${HEAPSTER_GROUP}
cli addenv -k ZABBIX_ADDR -v '"addr=10.3.150.251"' -g ${HEAPSTER_GROUP}
cli addenv -k ZABBIX_PORT -v '"port=10051"' -g ${HEAPSTER_GROUP}
cli addenv -k ZABBIX_PREFIX -v '"prefix=NS"' -g ${HEAPSTER_GROUP}
cli addenv -k ZABBIX_USER -v '"user=chengyue"' -g ${HEAPSTER_GROUP}
cli addenv -k ZABBIX_PASSWORD -v '"password=YmlnaXQxMjN-"' -g ${HEAPSTER_GROUP}

cli addenv -k SOURCE -v '"--source=kubernetes:http://${MASTER_IP}:8080?inClusterConfig=false"' -g ${HEAPSTER_GROUP}
cli addenv -k SINK -v '"--sink=zabbix:?${ZABBIX_ADDR}&${ZABBIX_PORT}&${ZABBIX_PREFIX}&${ZABBIX_USER}&${ZABBIX_PASSWORD}"' -g ${HEAPSTER_GROUP}
}

function f_delenv(){
#cli delenv -k MASTER_IP -g ${HEAPSTER_GROUP}
cli delenv -k ZABBIX_ADDR -g ${HEAPSTER_GROUP}
cli delenv -k ZABBIX_PORT -g ${HEAPSTER_GROUP}
cli delenv -k ZABBIX_PREFIX -g ${HEAPSTER_GROUP}
cli delenv -k ZABBIX_USER -g ${HEAPSTER_GROUP}
cli delenv -k ZABBIX_PASSWORD -g ${HEAPSTER_GROUP}

cli delenv -k SOURCE  -g ${HEAPSTER_GROUP}
cli delenv -k SINK    -g ${HEAPSTER_GROUP}
}

f_delenv
f_addenv
