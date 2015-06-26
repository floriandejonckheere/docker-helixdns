#!/bin/bash

/app/helixwatch.sh &

# HelixDNS panics every 5 minutes because etcd returns empty after a timeout.
# See https://github.com/mrwilson/helixdns/issues/15
while true; do
	helixdns -port 53 -forward 8.8.8.8:53 -etcd-address http://172.17.42.1:4001/
done
