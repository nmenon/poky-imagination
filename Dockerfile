FROM ghcr.io/crops/poky:ubuntu-22.04

USER root

LABEL org.opencontainers.image.source  "https://github.com/nmenon/poky-imagination"
LABEL org.opencontainers.image.description "Update of https://github.com/crops/poky-container/pkgs/container/poky to include kas and a reasonable dev env"

# Proxy and other ti specific packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apt-transport-https \
	socket \
	corkscrew \
	apt-utils \
	\
	vim \
	\
	python3-pip python3-newt && \
	python3 -m pip install kas && \
	\
	apt-get clean -y; \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY git-tunnel.sh /usr/bin/git-tunnel.sh
ENV GIT_PROXY_COMMAND=/usr/bin/git-tunnel.sh
