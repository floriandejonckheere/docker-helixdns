FROM debian:jessie
MAINTAINER Florian Dejonckheere <florian@floriandejonckheere.be>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -qy golang-go git make

RUN mkdir -p /usr/local/go/bin
ENV GOPATH /usr/local/go
ENV GOBIN /usr/local/go/bin
ENV PATH $PATH:$GOBIN

RUN go get github.com/mrwilson/helixdns
RUN go install github.com/mrwilson/helixdns

EXPOSE 53

CMD [ "helixdns", "-port", "53", "-forward", "8.8.8.8:53", "-etcd-address", "http://172.17.42.1:4001/" ]
