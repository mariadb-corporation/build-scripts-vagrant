#!/bin/bash

set -x

	debian_ver=`cat /etc/debian_version`
#	echo "Debian version: $debian_ver"
	dist_name=""
	echo $debian_ver  | grep "^6\." > /dev/null
	if [ $? -eq 0 ]; then
		dist_name="squeeze";
	fi
	echo $debian_ver  | grep "^7\." > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="wheezy";
        fi
        echo $debian_ver  | grep "^8\." > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="jessie";
        fi
	ubuntu_ver=`cat /etc/os-release | grep "VERSION_ID"`
	echo $ubuntu_ver | grep "12.04" > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="precise";
        fi
        echo $ubuntu_ver | grep "14.04" > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="trusty";
        fi

        echo $ubuntu_ver | grep "13.10" > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="saucy";
        fi
        echo $ubuntu_ver | grep "14.10" > /dev/null

        if [ $? -eq 0 ]; then
                dist_name="utopic";
        fi
        echo $ubuntu_ver | grep "15.04" > /dev/null
        if [ $? -eq 0 ]; then
                dist_name="vivid";
        fi


	if [ -z "$dist_name" ]; then
		dist_name="unknown"
	fi

echo $dist_name
