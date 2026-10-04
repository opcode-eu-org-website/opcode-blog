#!/bin/sh

for f in *; do [ -d "$f/.git" ] && (
	cd "$f"
	no_pub=false
	no_commit=false
	untracked=false
	
	if git log --decorate=short -1 | grep HEAD | grep pub-github > /dev/null
		then no_pub=false; else no_pub=true; fi
	
	if git status | grep -E 'Changes (not staged for commit|to be committed):' > /dev/null
		then no_commit=true; else no_commit=false; fi
	
	if git status | grep 'Untracked files:' > /dev/null
		then untracked=true; else untracked=false; fi
	
	if $no_pub || $no_commit || $untracked; then
		echo "$(basename $f)"
		$no_pub    && echo "    → HEAD != pub-github"
		$no_commit && echo "    → Not committed changes"
		$untracked && echo "    → Untracked files"
	fi
); done
