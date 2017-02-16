#! /bin/bash

if [ "$image_type" == "RPM" ] ; then
        build_info_path="$path_prefix/$platform/$platform_version/$arch/build_info"
else
        build_info_path="$path_prefix/$platform_family/dists/$platform_version/main/binary-$arch/build_info"
fi

echo "BUILD_PATH_INFO=$build_info_path" > $WORKSPACE/build_info_env_var_$BUILD_ID
