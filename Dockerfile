FROM debian:jessie
MAINTAINER Florian Dejonckheere <florian@floriandejonckheere.be>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -qy golang-go git make libc6 libsqlite3-0 libudev1 libdevmapper1.02.1 curl

# Don't mind my diry hacks
RUN ln -s /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1 /lib/x86_64-linux-gnu/libdevmapper.so.1.02

RUN mkdir -p /usr/local/go/bin /app
ENV GOPATH /usr/local/go
ENV GOBIN /usr/local/go/bin
ENV PATH $PATH:$GOBIN

RUN go get github.com/mrwilson/helixdns
RUN go install github.com/mrwilson/helixdns

ADD start.sh /app/start.sh
ADD helixwatch.sh /app/helixwatch.sh

EXPOSE 53

CMD /app/start.sh
