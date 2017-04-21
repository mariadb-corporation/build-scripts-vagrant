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

Direct execution of create_local_config.sh requires manuall paramters setting. 
It is easiler to ese create_local_config_libvirt.sh and create_local_config_docker.sh

Script usage:

```bash
. ~/build-scripts/test/create_local_config.sh <target> <name>
```
where

target - Maxscale binary repository name

name - name of virtual machines set

Note: '.' before command allows script to load all environmental variables (needed for 'maxscale-system-test').


All other parameters have to be defined as environmental variables before executing the script.

Examples of parameters definition can be found in the following scripts:

[test/create_local_config_libvirt.sh](test/create_local_config_libvirt.sh)

[test/create_local_config_docker.sh](test/create_local_config_docker.sh)

```bash
. ~/build-scripts/test/create_local_config_libvirt.sh <target> <name>
```

```bash
. ~/build-scripts/test/create_local_config_docker.sh <target> <name>
```

## Execute test

Clone and compile https://github.com/mariadb-corporation/maxscale-system-test

if environmental variables are not set:

```bash
. ~/build-scripts/test/set_env_vagrant.sh <name>
```

Execute single test by starting test binary or use ctest to run all or selected tests (see https://cmake.org/cmake/help/v3.8/manual/ctest.1.html)

To see test output: 
```bash
ctest -VV
```

## Destroying VMs

```bash
cd ~/mdbci/scripts
./clean_vms.sh <name>
```

## Reverting default snapshot

create_local_config.sh script takes one snapshot of recently created set of VMs. Snapshot name is 'clean'

If VMs are damaged during testing process it is easy to restore them:

```bash
cd ~/mdbci
./mdbci snapshot  revert --path-to-nodes <name> --snapshot-name clean
```

If needed, more snapshots can be created:


```bash
cd ~/mdbci
./mdbci snapshot  take --path-to-nodes <name> --snapshot-name <snapshot_name>
```
## Accessing VMs

```bash
cd ~/mdbci/<name>
vagrant ssh <vm_name>
```
where <vm_name> can be 'maxscale', 'node_XXX' or 'galera_XXX'.

```bash
. ~/build-scripts/test/set_env_vagrant.sh <name>
ssh -i $<vm_name>_keyfile $<vm_name>_whoami@$<vm_name>_network
```

examples:
```bash
ssh -i $node_002_keyfile $node_002_whoami@$node_002_network

ssh -i $maxscale_keyfile $maxscale_whoami@$maxscale_network
```

### Own VM configuration template

By default scripts use 
~/build-scripts/test/template.libvirt.json 
and 
~/build-scripts/test/template.docker.json 

These templates can be used as examples to create your own templates.

To use own template:

put your template file to ~/build-scripts/test/templates/

and define 'template_name' variable
```bash
export template_name=<your_template_filename>
. ~/build-scripts/test/create_local_config_libvirt.sh <target> <name>
```

## Troubleshooting

### vagrant is locked, waiting ...

```bash
rm ~/vagrant_lock
```


### Random VM creation failures

Plese check the amount of free memory and amount of running VMs

```bash
virsh list
docker ps
```
and remove all VMs and containers you do not need
