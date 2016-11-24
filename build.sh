#!/bin/bash

set -x

export image=$box
export target=`echo $target | tr -cd "[:print:]" `
export pre_repo_dir="$HOME/pre-repo/"

export image_type="RPM"
echo $box | grep -i ubuntu
if [ $? == 0 ] ; then
  export image_type="DEB"
  export platform_family="ubuntu"
fi
echo $box | grep -i deb
if [ $? == 0 ] ; then
  export image_type="DEB"
  export platform_family="debian"
fi

echo "target: $target"
echo "value:  $value"
export target=`echo $target | sed "s/?//g"`
export value=`echo $value | sed "s/?//g"`
echo "target: $target"
echo "value:  $value"

if [ "$source" == "TAG" ] ; then
	git reset --hard $value
	if [ $? -ne 0 ] ; then
                echo "Error reset to tag"
                exit 12
        fi

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

#sed -i "s/MAXSCALE_VERSION_PATCH \"0\"/MAXSCALE_VERSION_PATCH \"1.22\"/" cmake/macros.cmake

dist_sfx="$platform"."$platform_version"
export cmake_flags="$cmake_flags  -DPACKAGE=Y -DDISTRIB_SUFFIX=$dist_sfx"

mkdir -p $pre_repo_dir/$3/SRC
echo $sshuser
~/build-scripts/remote_build_new.sh
build_result=$?

shellcheck `find . | grep "\.sh"` | grep -i "POSIX sh"
if [ $? -eq 0 ] ; then
        echo "POSIX sh error are found in the scripts, exiting"
#        exit 1
fi
export repo_name=$target
export repo_path=${repo_path:-$HOME/repository}
export path_prefix="$repo_path/$repo_name/mariadb-maxscale/"

~/build-scripts/copy_repos/copy_repos.sh

if [ $build_result -ne 0 ] ; then
        echo "Build ERROR!"
        exit $build_result
fi

