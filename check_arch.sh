cat /proc/cpuinfo | grep cpu | grep POWER
if [ $? -ne 0 ] ; then

  dpkg --version
  if [ $? == 0 ] ; then
    dpkg -l | grep libc6
    export libc6_ver=`dpkg -l | sed "s/:amd64//g" |awk '$2=="libc6" { print $3 }'`
    dpkg --compare-versions $libc6_ver lt 2.14
    res=$?
  else
    export libc6_ver=`rpm --query glibc  --qf "%{VERSION}"`
    rpmdev-vercmp $libc6_ver 2.14
    if [ $? == 12 ] ; then
       res=0
    else
       res=1
    fi
    cat /etc/redhat-release | grep " 5\."
    if [ $? == 0 ] ; then
	res=0
    fi
    cat /etc/issue | grep "SUSE" | grep " 11 "
    if [ $? == 0 ] ; then
        res=0
    fi
  fi
set -x
  if [ $res != 0 ] ; then
    export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.42-linux-glibc_214-x86_64.tar.gz"
    export mariadbd_file="mariadb-5.5.42-linux-glibc_214-x86_64.tar.gz"
echo "embedded_ver: $embedded_ver"
    if [ "$embedded_ver" == "10.0" ] ; then
      export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-10.0.24-linux-glibc_214-x86_64.tar.gz"
      export mariadbd_file="mariadb-10.0.24-linux-glibc_214-x86_64.tar.gz"
    fi
  else 
    export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.42-linux-x86_64.tar.gz"
    export mariadbd_file="mariadb-5.5.42-linux-x86_64.tar.gz"
    if [ "$embedded_ver" == "10.0" ] ; then
      export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-10.0.24-linux-x86_64.tar.gz"
      export mariadbd_file="mariadb-10.0.24-linux-x86_64.tar.gz"
    fi
  fi
else
	endian=`echo -n I | od -to2 | head -n1 | cut -f2 -d" " | cut -c6`
	if [ $endian == 0 ] ; then 
                export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.41-linux-ppc64.tar.gz"
                export mariadbd_file="mariadb-5.5.41-linux-ppc64.tar.gz"
		cat /etc/redhat-release | grep " 6\."
		if [ $? == 0 ] ; then
		     export mariadbd_link="http://jenkins.engskysql.com/x/rhel6/mariadb-5.5.41-linux-ppc64.tar.gz"
		fi

	else
	        export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.41-linux-ppc64le.tar.gz"
        	export mariadbd_file="mariadb-5.5.41-linux-ppc64le.tar.gz"
	fi
fi

