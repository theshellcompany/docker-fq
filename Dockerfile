FROM debian:bookworm
LABEL maintainer="erik@theshell.company"

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GO_VERSION 1.22.4
ENV GOPATH /opt/fq
ENV PATH "$PATH:/usr/local/go/bin"
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV HOME /home/nonroot
ENV USER nonroot

# setup install as root
USER root

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -yq --no-install-recommends ca-certificates wget

# installation of Go
WORKDIR /tmp
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar xvf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local/ && \
    rm /tmp/go{GO_VERSION}.linux-amd64.tar.gz

# installation of fq
WORKDIR /opt
RUN go install github.com/wader/fq@master

# creation of the nonroot user
RUN groupadd -r nonroot && \
    useradd -m -g nonroot -d /home/nonroot -s /usr/sbin/nologin -c "nonroot user" nonroot &&
    mkdir -p /home/nonroot && \
    chown -R nonroot:nonroot /home/nonroot

# switching to nonroot
USER nonroot
WORKDIR /home/nonroot

ENTRYPOINT ["/opt/fq/bin/fq"]
