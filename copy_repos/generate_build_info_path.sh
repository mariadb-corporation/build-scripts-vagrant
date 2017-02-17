#! /bin/bash

set -x

web_prefix=$(echo $path_prefix | sed "s|$HOME/repository/||g")

if [ "$image_type" == "RPM" ] ; then
        export build_info_path="$web_prefix/$platform/$platform_version/$arch/build_info"
else
        export build_info_path="$web_prefix/$platform_family/dists/$platform_version/main/binary-$arch/build_info"
fi

echo "BUILD_PATH_INFO=$web_prefix" > $WORKSPACE/build_info_env_var_$BUILD_ID
