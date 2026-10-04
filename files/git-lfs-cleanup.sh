#!/bin/bash

if [ "$(git rev-parse --is-bare-repository)" == "false" ]; then
	# git lfs prune --force --no-verify-remote
	echo mv "$(git rev-parse --git-dir)/lfs/objects/" /tmp
	exit
fi

# git lfs prune --recent --no-verify-remote

lfs_dir="$(git rev-parse --git-dir)/lfs/objects"
if [ ! -d "$lfs_dir" ]; then
	echo "$lfs_dir do not exist"
	exit 1
fi

join -j 1 -a 1 <(git lfs ls-files -l -a | sort) <(git lfs ls-files -l master | sort | awk '{printf("%s  MASTER\n", $1);}') | awk '$NF!="MASTER" {
	path = sprintf("'"$lfs_dir"'/%s/%s/%s", substr($1, 1, 2), substr($1, 3, 2), $1)
	print($1)
	system(sprintf(" [ -f \"%s\" ] && echo mv \"%s\" /tmp", path, path))
}'
