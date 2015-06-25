#!/bin/bash

/app/helixwatch.sh &
helixdns -port 53 -forward 8.8.8.8:53 -etcd-address http://172.17.42.1:4001/
