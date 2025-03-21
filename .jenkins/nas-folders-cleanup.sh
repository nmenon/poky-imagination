#!/bin/bash

# Folder Names start with 20 -> 2024-02-15 or so.
set -x
usage() {
	echo "$0 base_folder num_folders_to_keep"
}
if [ -z "$1" ]; then
	echo "Please provide base folder"
	usage
	exit 1
else
	cd $1
fi
if [ -z "$2" ]; then
	echo "Please provide num_folders to keep"
	usage
	exit 1
else
	KEEP_FOLDERS=$2
fi

latest=`ls -d *|grep '^20'|sort |tail -n 1`

if [ -z "$latest" ]; then
	exit 0
fi

rm -f latest
ln -s "$latest" latest

NUM_FOLDERS=`ls -d *|grep '^20'|wc -l`
if [ $NUM_FOLDERS -lt $KEEP_FOLDERS ]; then
	exit 0
fi

DEL_FOLDERS=`expr $NUM_FOLDERS - $KEEP_FOLDERS`
CLEAN_UP_LIST=`ls -d *|grep '^20'|sort| head -n $DEL_FOLDERS`

if [ -z "$CLEAN_UP_LIST" ]; then
	exit 0
fi

rm -rf $CLEAN_UP_LIST
