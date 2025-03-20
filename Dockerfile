FROM crops/poky:ubuntu-22.04

USER root

# Proxy and other ti specific packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apt-transport-https \
	socket \
	corkscrew \
	apt-utils

# basic editor packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	vim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	python3-pip python3-newt && \
	python3 -m pip install kas

RUN echo "**** cleanup ****" && \
	apt-get clean -y; \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY git-tunnel.sh /usr/bin/git-tunnel.sh
ENV GIT_PROXY_COMMAND=/usr/bin/git-tunnel.sh
