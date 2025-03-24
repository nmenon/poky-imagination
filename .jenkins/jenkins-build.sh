#!/bin/bash

set -e
set -x
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_DIR=$SCRIPT_DIR/..

export TZ='America/Chicago'

usage() {
	echo "Usage:"
	echo "$0 -c cache_folder -w work_base_folder -b build_yaml -r nas_server -d nas_directory -k num_images_to_keep_in_nas -m min_space_in_bytes"
}

while getopts "c:w:b:r:d:k:m:?h" opt; do
	case $opt in
	c)
		CACHE_FOLDER=$OPTARG
	;;
	w)
		WORK_DIR=$OPTARG
	;;
	b)
		BUILD_YML=$OPTARG
	;;
	r)
		NAS_SSH=$OPTARG
	;;
	d)
		NAS_DIR=$OPTARG
	;;
	k)
		KEEP_NUM_IMAGES=$OPTARG
	;;
	m)
		MIN_SPACE_BYTES=$OPTARG
	;;
	?|h)
		usage
		exit 0
	;;
	esac
done
if [ x$CACHE_FOLDER = x ]; then
	echo "Please provide cache folder location for the build"
	usage
	exit 1
fi
if [ x$WORK_DIR = x ]; then
	echo "Please provide Work directory to build"
	usage
	exit 1
fi
if [ x$BUILD_YML = x ]; then
	echo "Please provide what build to make"
	usage
	exit 1
fi
if [ ! -f "$BASE_DIR/$BUILD_YML" ]; then
	echo "$BASE_DIR/$BUILD_YML Does not exist?"
	usage
	exit 1
fi
if [ x$NAS_SSH = x ]; then
	echo "Please provide NAS SSH details"
	usage
	exit 1
fi
if [ x$KEEP_NUM_IMAGES = x ]; then
	echo "Please provide Number of build folders to retain in NAS"
	usage
	exit 1
fi
if [ x$MIN_SPACE_BYTES = x ]; then
	echo "Please provide minimum space to permit build"
	usage
	exit 1
fi

cd $BASE_DIR

MY_JOB_FOLDER=`date "+%Y-%m-%d-%H-%M-%S"`
WORK_FOLDER=$WORK_DIR/$MY_JOB_FOLDER
REMOTE_FOLDER=$NAS_DIR/$MY_JOB_FOLDER

if [ -d "$WORK_DIR" ]; then
	# Let us start from scratch please
	rm -rf "$WORK_DIR"
fi

mkdir -p $WORK_FOLDER

# Make sure NAS folder exists
ssh $NAS_SSH ls -d $NAS_DIR || ssh $NAS_SSH mkdir -p $NAS_DIR

# Check if we have spare storage in NAS
NAS_SPACE=`ssh $NAS_SSH df  $NAS_DIR |grep -v "Used"|sed -e "s/\s\s*/|/g"|cut -d '|' -f4`
MY_SPACE=`df  $WORK_DIR |grep -v "Used"|sed -e "s/\s\s*/|/g"|cut -d '|' -f4`

if [ $NAS_SPACE -lt $MIN_SPACE_BYTES ]; then
	echo "NAS IS RUNNING OUT OF SPACE. NOT BUILDING! $MIN_SPACE_BYTES < $NAS_SPACE"
	exit 1
fi
if [ $MY_SPACE -lt $MIN_SPACE_BYTES ]; then
	echo "BUILD SERVER OUT OF SPACE. NOT BUILDING! $MIN_SPACE_BYTES < $MY_SPACE"
	exit 1
fi

# New build nodes may or may not have folders. create a few
ARTIFACT_FOLDER=$WORK_FOLDER/build/tmp/deploy/images/genericarm64/


if [ ! -d "$CACHE_FOLDER" ]; then
	mkdir -p $CACHE_FOLDER
fi

APPEND_YML="caches.yml:image.yml:pokyuser.yml"

$BASE_DIR/kas-build.sh -C 1 -c  $CACHE_FOLDER -w $WORK_FOLDER -e "kas build $BUILD_YML:$APPEND_YML"

YR=`date "+%Y"`
LOCAL_FILES=`ls $ARTIFACT_FOLDER/*|grep -v "\-$YR"`
du -hs $ARTIFACT_FOLDER/*

# Move files to remote NAS
ssh $NAS_SSH mkdir -p $REMOTE_FOLDER
scp $LOCAL_FILES $NAS_SSH:$REMOTE_FOLDER

# Cleanup extra folders
scp $SCRIPT_DIR/nas-folders-cleanup.sh $NAS_SSH:/tmp/nas-folder-cleanup-$MY_JOB_FOLDER.sh

# Remove cleanup script from NAS
ssh $NAS_SSH bash /tmp/nas-folder-cleanup-$MY_JOB_FOLDER.sh $NAS_DIR $KEEP_NUM_IMAGES
ssh $NAS_SSH rm -f /tmp/nas-folder-cleanup-$MY_JOB_FOLDER.sh

# Clean up our Build to free up build server space
if [ -d "$WORK_DIR" ]; then
	# Let us start from scratch please
	rm -rf "$WORK_DIR"
fi
