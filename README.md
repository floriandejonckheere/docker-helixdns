# HelixDNS
HelixDNS is a lightweight DNS server backed by etcd. This repository contains a docker image for automatic service discovery.

## Usage

Build and run the docker container using `build.sh` and at least the parameters in `run.sh`. Configure your root domain in the environment variable `ROOT_DOMAIN`. If your root domain is `/io/docker/services`, all containers will be available under `<container_name>.services.docker.io`.

Start every container you want resolution to work for with the `--dns=172.17.42.1` parameter, where 172.17.42.1 is the IP address of the Docker network bridge. Alternatively, start the Docker daemon with this parameter and resolution will work for every container.

Test your setup by verifying the output of a DNS resolution command:
```
$ dig A nginx.services.docker.io
nginx.services.docker.io. 5 IN	A	172.17.0.128
```
