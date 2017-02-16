#! /bin/bash

set -x

web_prefix=$(echo $path_prefix | sed 's|/home/vagrant/repository/||g')

if [ "$image_type" == "RPM" ] ; then
        build_info_path="$web_prefix/$platform/$platform_version/$arch/build_info"
else
        build_info_path="$web_prefix/$platform_family/dists/$platform_version/main/binary-$arch/build_info"
fi

echo "BUILD_PATH_INFO=$build_info_path" > $WORKSPACE/build_info_env_var_$BUILD_ID
