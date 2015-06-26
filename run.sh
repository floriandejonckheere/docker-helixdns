#!/bin/bash

docker run -d --name helixdns \
	--restart=always \
	-p 172.17.42.1:53:53/udp \
	-v /bin/docker:/bin/docker \
	-v /var/run/docker.sock:/var/run/docker.sock \
	thalariond/helixdns
