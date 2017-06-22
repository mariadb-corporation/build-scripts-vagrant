# Release process

## 1. Create tag

Create tag 'maxscale-x.x.x' and push this tag to the repository.

## 2. Build and upgrade test

[Build_all]/http://127.0.0.1:8089/job/build_all/) Jenkins job should be used to build 
repositories.

Usually two run are needed: release and debug builds.


Parameters to define (other parameters by default):

**source**
```
refs/tags/maxscale-x.x.x
```

**target**
Debug build:
```
maxscale-x.x.x-debug
```

Release build:
```
maxscale-x.x.x-release
```

**cmake_flags**

Debug build:
```
-DBUILD_TESTS=Y -DCMAKE_BUILD_TYPE=Debug -DBUILD_MMMON=Y -DBUILD_CDC=Y
```

Release build:
```
-DBUILD_TESTS=N -DBUILD_MMMON=Y -DBUILD_CDC=Y
```

**run_upgrade_test**

```
yes
```

**old_target**

Name of some existing Maxscale repository 
(please check http://max-tst-01.mariadb.com/ci-repository/
before build).

```
maxscale-y.y.y-release
```

### Options for 1.4.x build

For 1.4.x default values of following parameters should changed:

**use_mariadbd**

```
yes
```


**cnf_file**

```
maxscale.cnf.minimum.1.4.4
```

**maxadmin_command**


```
maxadmin -pmariadb show services
```

## 3. Copying to code.mariadb.com

ssh code.mariadb.com with your LDAP credentials.

Create directories and copy repositories files:

```bash
cd  /home/mariadb-repos/mariadb-maxscale/
mkdir x.x.x
mkdir x.x.x-debug
cd x.x.x
rsync -avz  --progress --delete -e ssh  vagrant@max-tst-01.mariadb.com:/home/vagrant/repository/maxscale-x.x.x-release/mariadb-maxscale/ .
cd ../x.x.x-debug
rsync -avz  --progress --delete -e ssh  vagrant@max-tst-01.mariadb.com:/home/vagrant/repository/maxscale-x.x.x-debug/mariadb-maxscale/ .
```

## 4. Email webops-requests@mariadb.com

Email example:

```
Hello,

Please publish Maxscale x.x.x binaries on web page. Repos are on code.mariadb.com /home/mariadb-repos/mariadb-maxscale/x.x.x
symlink 'x.x' should be set to 'x.x.x'
symlink 'latest' [should|should NOT] be set to 'x.x.x'

Also please make sure that debug binaries are not visible from https://mariadb.com/my_portal/download/maxscale
```
