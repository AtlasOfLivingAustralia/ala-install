# ALA Installation Scripts
This project contains [Ansible](http://www.ansible.com/) playbooks for setting up ALA components on Ubuntu 16 machines.
This project includes a playbook for setting up the [ALA demo ](http://ala-demo.gbif.org).

## Ansible version

### The current supported version is: **2.5.4**

The playbooks and roles in this repository have been developed and tested against the above version.

NOTE: many linux packages have an older version of Ansible (1.7 or even 1.5). You will need to update your packages and upgrade ansible first.

For APT:

```
$ sudo apt-get install software-properties-common python-dev git python-pip
$ sudo pip install setuptools
$ sudo pip install -I ansible==[version]
```

where ```[version]``` is the supported version listed above.

For OSX:

```
$ sudo easy_install pip
$ sudo pip install -I ansible==[version]
```

where ```[version]``` is the supported version listed above.

If you see this error:
```
ERROR: apache2_module is not a legal parameter in an Ansible task or handler.
```
then you have an older version of Ansible.

## Setup the Living Atlas demo

Below are some instructions for setting up the Living Atlas demo with Ansible & Vagrant on your local machine or laptop.

#### 1. Vagrant
[Vagrant](http://www.vagrantup.com) can be used to test ansible playbooks on your local machine. To use this, you will need to install
[VirtualBox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com). We recommend using vagrant version 2.0.4. Earlier versions of vagrant will not work with the ```VagrantFile``` in this repository.

For Debian/Ubuntu:
```
$ sudo apt-get install virtualbox virtualbox-dkms virtualbox-qt
$ cd ~/Downloads
$ wget https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.deb
$ sudo dpkg -i vagrant_2.0.4_x86_64.deb
$ vagrant plugin install vagrant-disksize
```

The ```vagrant/ubuntu-xenial``` directory contains configurations that can used with [VirtualBox](https://www.virtualbox.org/) to bring up a VH for deploying against.  

This is included only to simplify local testing, but any server Ubuntu 16.x could be used.  

To create a virtual machine with vagrant:

```
$ cd vagrant/ubuntu-xenial
$ vagrant up
```

*Double check IP address in Vagrantfile*


The first execution of this downloads the Ubuntu image which can take 20 minutes or more. The ALA sample inventories (in the ansible/inventories/vagrant directory) refer to the VM as 'vagrant1' rather than the IP address. For this to work, you will need to add the following entries to you ```/etc/hosts``` file (alternatively, you can edit the inventory file and replace 'vagrant1' with the IP address of your VM).
```
10.1.1.4  vagrant1 vagrant1.ala.org.au demo.vagrant1.ala.org.au
```

Once ready you can ssh to your VM like so:

```
$ vagrant ssh
```

with password ```vagrant```.

If your system cannot find a route to 10.1.1.4, you can ssh via `ssh -p 2223 vagrant@localhost` and use `ifconfig -a` to see what your virtual machine thinks is happening.

You need to disable strict host key checking in ssh, you will need to create or only add the folling entries to you ```~/.ssh/config``` file (alternatively, you can configure this).

```
Host *
    StrictHostKeyChecking no
```


You may get public key denied error, then you can try:
```
ssh vagrant@10.1.1.4 -i ~/.vagrant.d/insecure_private_key
```

If your system cannot find a route to 10.1.1.3, you can ssh via `ssh -p 2223 vagrant@localhost` and use `ifconfig -a` to see what your virtual machine thinks is happening.


#### 2. Ansible

An [Ansible inventory file](http://docs.ansible.com/intro_inventory.html) is included that allows for running against a Vagrant configured VM (see ```inventories/vagrant/demo-vagrant```). Other inventories can easily be crafted to match other infrastructure.  

Note: any application deployed as part of a playbook requires the following two variables to be defined in the inventory: ```<applicationName>_hostname``` variable and ```<applicationName>_context_path```. See the readme file in the ansible directory for more information.

To run Ansible against your vagrant instance you need to locate the correct key file (e.g. the default insecure vagrant file if using the Vagrant config for testing):

```
$ cd ansible
$ ansible-playbook -i inventories/vagrant/demo-vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key --user vagrant --become
```

Once completed successfully you can view the demo on http://demo.vagrant1.ala.org.au/ 

## Installing the ALA demo on EC2 or other cloud providers

There is an inventory you can use to setup the demo on a cloud provider [here](ansible/inventories/living-atlas).
An Ubuntu 16 instance with 15GB of RAM and 4 CPUs is recommended. The scripts where tested on 30th April 2015 and took approximately 20 mins to run on a EC2 instance.

Here are the steps to run with this inventory:

 *  Create your Ubuntu 16 instance. Make sure your machine is open on *ports 22, 80 and 443*. 

 *  Add the following to your */etc/hosts* file on the machine your are running ansible from (e.g. your laptop):
```
12.12.12.12	ala-demo	ala-demo.org 
```
You'll need to replace "12.12.12.12" with the IP address of your newly created Ubuntu 16 instance.

 * Run the following:
```
ansible-playbook --private-key ~/.ssh/MyPrivateKey.pem --user ubuntu --become -i ansible/inventories/living-atlas ansible/ala-demo.yml
```
 * View http://living-atlas.org
 
##### That worked, now what do I do ?
 * Have a look at the [documentation](https://github.com/AtlasOfLivingAustralia/documentation/wiki/First-data-resource) and load a data resource.


### Vagrant

The ```inventories/vagrant/``` directory contains sample inventories for most playbooks that will work against a Ubuntu Vagrant virtual machine. To use these inventories, add an entry for ```vagrant1``` and ```vagrant1.ala.org.au``` to your hosts file, or edit the inventory file and replace the hostnames and URLs, then run

```
ansible-playbook -i inventories/vagrant/<inventoryFile> <playbook>.yml --private-key ~/.vagrant.d/insecure_private_key --user vagrant --become
```

The inventory files can easily be modified to work against other virtual machines or servers (e.g. Nectar or CSIRO) simply by modifying the server and host names appropriately.

## Notes for different environments (CSIRO/Nectar)

There are some minor differences for running these playbooks against Nectar VMs, CSIRO IM&T VMs and Vagrant VMs.
In each case you will need to create an inventory file that points to your VM(s).


For IM&T virtual machines:
```
$ ansible-playbook -i inventories/demo ala-demo.yml --user <CSIRO_IDENT> --become --ask-pass --ask-sudo-pass
```

For Nectar VMs:
```
$ ansible-playbook -i inventories/sandbox-nectar sandbox.yml --private-key <PATH_TO_YOUR_PEM_FILE> --user root
```
If you do not have private key of root, you can use your own id as follows: Make sure you have sudo permission
```
ansible-playbook -i ~/src/ansible-inventories/sandbox-nectar sandbox.yml --private-key <private key path> --user <id> -s --ask-sudo-pass
```
Note Nectar VMs will require an edit of the /etc/hosts file on the VM so that it recognises its own host name.

For Vagrant VMs:
```
$ ansible-playbook -i ansible/inventories/ala-demo ansible/ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key --user vagrant --become
```

For EC2 instances:
```
$ ansible-playbook -i inventories/solr-amazon solr-standalone.yml --private-key ~/.ssh/dmartin-amazon.pem --user ubuntu --become
```

## Required inventory properties
Most ALA playbooks will require at a minimum the following set of inventory properties:

* ```<applicationName>_hostname``` - The hostname portion of the url used to access the deployed service (e.g. 'ala.org.au' in the url https://www.ala.org.au/myApp)
* ```<applicationName>_context_path``` - The context path portion of the url used to access the deployed service (e.g. 'myApp' in the url https://www.ala.org.au/myApp). Note: this property should be blank for the context root, NOT a slash).
* ```auth_base_url``` - The HTTP*S* URL of the authentication server (e.g. https://auth.ala.org.au)
* ```auth_cas_url``` - The HTTP*S* URL of the CAS application on the authentication server (e.g. https://auth.ala.org.au/cas)
