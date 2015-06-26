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


# Etcd root namespace, no trailing slash
ROOT="/helix${ROOT_DOMAIN:-/io/docker}"
# Etcd address
ETCD="http://172.17.42.1:4001"

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
	echo "Setting ${ROOT}${NAME} to ${IP}"
	curl -s -L "${ETCD}/v2/keys${ROOT}${NAME}/A" -XPUT -d value="${IP}" > /dev/null
}

# Remove a record
function remove_record() {
	NAME=$(docker inspect --format='{{.Name}}' ${CONTAINER})
	echo "Removing ${ROOT}${NAME}"
	curl -s -L "${ETCD}/v2/keys${ROOT}${NAME}" -XDELETE > /dev/null
}

# Watch function
function watch_events {
	docker events | while read -r LINE; do
		CONTAINER=$(echo ${LINE} | cut -d ' ' -f 2 | tr -d :)
		EVENT=$(echo ${LINE} | cut -d ' ' -f 5)
		case ${EVENT} in
			start)
				update_record ${CONTAINER}
				;;
			die)
				remove_record ${CONTAINER}
				;;
		esac
	done
}

update_all_records
watch_events
