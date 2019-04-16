#!/bin/bash

## git hook for enforce update working tree of
## non-bare repo with denyCurrentBranch = ignore
## 
## 
## Copyright (c) 2019 Robert Ryszard Paciorek <rrp@opcode.eu.org>
## 
## MIT License
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

if [ "$GIT_DIR" = "." -a -d .git ]; then
	echo "work-tree inside .git dir is suspicious ... stop" > /dev/stderr
	exit 1
fi

if [ "$GIT_DIR" = "." ]; then
	HEAD=`git rev-parse --short HEAD`
	cd ..
	unset GIT_DIR
	if [ "$HEAD" != `git rev-parse --short HEAD` ]; then
		echo "Diffrent HEAD after cd ... stop" > /dev/stderr
	fi
fi

if [ ! -f .git/config ]; then
	echo "Unable to find work-tree ... stop" > /dev/stderr
	exit 1
fi
if echo "/$PWD/" | grep "/.git/" >& /dev/null; then
	echo "work-tree inside .git dir is suspicious ... stop" > /dev/stderr
	exit 1
fi


info1="=== post-recive hook on `hostname` ==="
info2=$(eval printf '=%.0s' {1..${#info1}})

echo -e "\n$info1"

git reset --hard
git clean -df
git checkout -f .

echo -e "$info2\n"

