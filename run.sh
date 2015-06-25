#!/bin/bash

docker run -d --name helixdns \
	-v /bin/docker:/bin/docker \
	-v /var/run/docker.sock:/var/run/docker.sock \
	thalariond/helixdns
