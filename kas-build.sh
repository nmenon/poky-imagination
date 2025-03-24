#!/bin/bash

DEFAULT_IMAGE=ghcr.io/nmenon/poky-crops-kas-env:latest
IMG_NAME="${IMG_NAME:-$DEFAULT_IMAGE}"

EXECUTE=""
while getopts "c:l:w:b:C:e:?h" opt; do
	case $opt in
	c)
		CACHE_FOLDER=$OPTARG
	;;
	l)
		OE_LOCAL_FOLDER=$OPTARG
	;;
	w)
		WORK_DIR=$OPTARG
	;;
	b)
		BUILD_DIR=$OPTARG
	;;
	C)
		CLONE_DEPTH=$OPTARG
	;;
	e)
		EXECUTE=$OPTARG
	;;
	?|h)
		echo "Usage:"
		echo "$0 [-c cache_folder_path] [-l oe_local_folder] [-w kas_work_dir] [-C clone_depth] [-b kas_build_dir] [-e 'what to run']"
		exit 0
	;;
	esac
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ x == x"$OE_LOCAL_FOLDER" ]; then
	OE_LOCAL_FOLDER=$SCRIPT_DIR/
fi

DOCKER_OPTIONS="-v ${OE_LOCAL_FOLDER}:/workdir --workdir=/workdir --security-opt seccomp=unconfined"
if [ -z "$TZ" ]; then
	TZ=`timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g'`
fi
DOCKER_OPTIONS+=" -e TZ=$TZ"
if [ -d $HOME/.ssh ]; then
	DOCKER_OPTIONS+=" -v $HOME/.ssh:/home/pokyuser/.ssh"
fi

if [ -n "$SSH_AUTH_SOCK" ]; then
	SSHAUTH_SOCKD=`dirname $SSH_AUTH_SOCK`
	DOCKER_OPTIONS+=" -v $SSHAUTH_SOCKD:$SSHAUTH_SOCKD"
	DOCKER_OPTIONS+=" -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
fi

if [ x"$CACHE_FOLDER" == x ]; then
	CACHE_FOLDER=$SCRIPT_DIR
fi

if [ ! -d "$CACHE_FOLDER" ]; then
	echo "$CACHE_FOLDER cache directory does'nt exist?"
	exit 2
fi
DOCKER_OPTIONS+=" -v $CACHE_FOLDER:/cache"

if [ x"$BUILD_DIR" != x ]; then
	KAS_BUILD_DIR=/build
	DOCKER_OPTIONS+=" -e KAS_BUILD_DIR=/build -v $BUILD_DIR:/build"
	if [ ! -d "$BUILD_DIR" ]; then
		echo "$BUILD_DIR build directory does'nt exist?"
		exit 2
	fi
fi
if [ x"$WORK_DIR" != x ]; then
	KAS_WORK_DIR=/work
	DOCKER_OPTIONS+=" -e KAS_WORK_DIR=/work -v $WORK_DIR:/work"
	if [ ! -d "$WORK_DIR" ]; then
		echo "$WORK_DIR work directory does'nt exist?"
		exit 2
	fi
fi
if [ x"$CLONE_DEPTH" != x ]; then
	DOCKER_OPTIONS+=" -e KAS_CLONE_DEPTH=$CLONE_DEPTH"
fi


if [ "$IMG_NAME" = "$DEFAULT_IMAGE" ]; then
	docker pull "${IMG_NAME}"
	true
fi
# If we wanted to get to bash shell:
if [ x"$EXECUTE" == x ]; then
	docker run --rm -ti -e BUILD_BRANCH -e BUILD_NUMBER ${DOCKER_OPTIONS} "${IMG_NAME}"
	RES=$?
else
	docker run --rm -e BUILD_BRANCH -e BUILD_NUMBER ${DOCKER_OPTIONS} "${IMG_NAME}" $EXECUTE
	RES=$?
fi

exit $RES
