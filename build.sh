#!/bin/bash

set -x

export image=$box
export target=`echo $target | tr -cd "[:print:]" `
export pre_repo_dir="/home/turenko/pre-repo/"

echo "target $target"

if [ "$source" == "TAG" ] ; then
	git reset --hard $value
fi

if [ "$source" == "BRANCH" ] ; then
	git branch $value origin/$value
        git checkout $value
	git pull
       	if [ $? -ne 0 ] ; then
		echo "Error checkout branch $branch"
                exit 12
        fi
fi

if [ "$source" == "COMMIT" ] ; then
	git reset --hard $value
        if [ $? -ne 0 ] ; then
       	        echo "Error resetting tree to the commit $value"
               	exit 12
        fi
fi

commitID=`git log | head -1 | sed "s/commit //"`
echo "commitID $commitID"

if [ "$5" != "" ] ; then
  cd $5
fi

export cmake_flags="$cmake_flags  -DPACKAGE=Y"

mkdir -p $pre_repo_dir/$3/SRC

~/build-scripts/remote_build_new.sh
build_result=$?

shellcheck `find . | grep "\.sh"` | grep -i "POSIX sh"
if [ $? -eq 0 ] ; then
        echo "POSIX sh error are found in the scripts, exiting"
        exit 1
fi

if [ $build_result -ne 0 ] ; then
        echo "Build ERROR!"
        exit $build_result
fi

