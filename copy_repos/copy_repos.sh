#!/bin/bash

if [ "$image_type" == "RPM" ] ; then
        arch=`ssh $sshopt "arch"`
        rm -rf $path_prefix/$platform/$platform_version/$arch/
        mkdir -p $path_prefix/$platform/$platform_version/$arch/
        cp -r ~/repo/$repo_name/$box/* $path_prefix/$platform/$platform_version/$arch/
	env > $path_prefix/$platform/$platform_version/$arch/build_info
        cd $path_prefix/$platform
        ln -s $platform_version "$platform_version"server
        ln -s $platform_version "$platform_version"Server

        echo "copying done"
        ./generate_build_info_path.sh
else
        arch=`ssh $sshopt "dpkg --print-architecture"`
        rm -rf $path_prefix/$platform_family/dists/$platform_version/main/binary-"$arch"
        rm -rf $path_prefix/$platform_family/dists/$platform_version/main/binary-i386
        mkdir -p $path_prefix/$platform_family/
        cp -r ~/repo/$repo_name/$box/* $path_prefix/$platform_family/
	env > $path_prefix/$platform_family/dists/$platform_version/main/binary-"$arch"/build_info
        ./generate_build_info_path.sh
fi

