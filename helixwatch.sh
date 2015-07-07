#!/bin/bash
#
# helixwatch - Bind Docker containers to HelixDNS records
#
# This script will continuously watch all running docker containers, and
# set HelixDNS records based on the container name to the IP address.
#
# For example, if a container named 'postgresql' was started, stopped or restarted,
# the corresponding record '/helix/<namespace>/postgresql/A' will be set to the
# container's IP address.
#
# Reverse DNS lookups via PTR records are supported.


HELIX="/helix"
# Etcd root namespace, no trailing slash
# WARNING: this key will be recursively deleted on startup!
ROOT="${HELIX}${NAMESPACE:-/io/docker}"
# Etcd address
ETCD="http://172.17.42.1:4001"

function purge_all_records() {
	echo "$(date +'%Y/%m/%d %H:%M:%S') Purging ${ROOT}"
	curl -s -L "${ETCD}/v2/keys${HELIX}/?recursive=true" -XDELETE > /dev/null
}

# Enumerate all running containers, and add a record using their name
function update_all_records() {
	for CONTAINER in $(docker ps -q); do
		update_record ${CONTAINER}
	done
}

# Add a record using a container identifier
function update_record() {
	NAME=$(docker inspect --format='{{.Name}}' ${CONTAINER})
	IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' ${CONTAINER})
	echo "$(date +'%Y/%m/%d %H:%M:%S') Setting ${ROOT}${NAME} to ${IP}"
	curl -s -L "${ETCD}/v2/keys${ROOT}${NAME}/A" -XPUT -d value="${IP}" > /dev/null
	ARPA="$(echo ${IP} | sed -e 's/\([0-9]*\).\([0-9]*\).\([0-9]*\).\([0-9]*\)/\1\/\2\/\3\/\4/g')"
	echo "$(date +'%Y/%m/%d %H:%M:%S') Setting ${ARPA} to ${NAME:1}.${ROOT_DOMAIN}"
	curl -s -L "${ETCD}/v2/keys${HELIX}/arpa/in-addr/${ARPA}/PTR" -XPUT -d value="${NAME:1}.${ROOT_DOMAIN}." > /dev/null
}

# Remove a record
function remove_record() {
	NAME=$(docker inspect --format='{{.Name}}' ${CONTAINER})
	echo "[$(date +'%Y/%m/%d %H:%M:%S')] Removing ${ROOT}${NAME}"
	curl -s -L "${ETCD}/v2/keys${ROOT}${NAME}" -XDELETE > /dev/null
}

# Watch function
function watch_events {
	docker events | while read -r LINE; do
		CONTAINER=$(echo ${LINE} | cut -d ' ' -f 2 | tr -d :)
		EVENT=$(echo ${LINE} | cut -d ' ' -f 5)
		case ${EVENT} in
			start)
				echo "[$(date +'%Y/%m/%d %H:%M:%S')] Container ${CONTAINER} started..."
				update_record ${CONTAINER}
				;;
			die)
				echo "[$(date +'%Y/%m/%d %H:%M:%S')] Container ${CONTAINER} stopped..."
				remove_record ${CONTAINER}
				;;
		esac
	done
}

purge_all_records
update_all_records
watch_events
