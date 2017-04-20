# Local deployment

## Prepare MDBCI environment

Libvirt, Docker and Vagrant with a set of plugins are needed for MDBCI. All packages can be installed by script 
https://github.com/OSLL/mdbci/blob/integration/scripts/install_mdbci_dependencies.sh 
(Debian-based Linux distributions)
or 
https://github.com/OSLL/mdbci/blob/integration/scripts/install_mdbci_dependencies_yum.sh
(RPM-based Linux distributions)

See https://github.com/OSLL/mdbci/blob/integration/PREAPARATION_FOR_MDBCI.md for detailed instructions.

## Creating VMs for local tests

[test/create_local_config.sh](test/create_local_config.sh) script creates a set of virtual machines
(1 maxscale VM, 4 Master/Slave and 4 Galera).

Script usage:

```bash
create_local_config.sh target name
```
where

target - Maxscale binary repository name

name - name of virtual machines set


All other parameters have to be defined as environmental variables before executing the script.

Examples of parameters definition can be found in the following scripts:

[test/create_local_config_libvirt.sh](test/create_local_config_libvirt.sh)

[test/create_local_config_docker.sh](test/create_local_config_docker.sh)

