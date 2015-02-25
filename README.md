# ALA Installation Scripts
This project contains [Ansible](http://www.ansible.com/) playbooks for setting up ALA components on Ubuntu 14 machines.
This project includes a playbook for setting up the [ALA demo ](http://ala-demo.gbif.org).

## Ansible version

The playbooks and roles in this repository require Ansible 1.8 or above.

## Setup the ALA demo

Below are some instructions for setting up the [ALA demo](http://ala-demo.gbif.org) with Ansible & Vagrant on your local machine.

#### 1. Vagrant
[Vagrant](http://www.vagrantup.com) can be used to test ansible playbooks on your local machine. To use this, you will need to install
[VirtualBox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com).

The ```vagrant/ubuntu``` directory contains configurations that can used with [VirtualBox](https://www.virtualbox.org/) to bring up a VH for deploying against.  

This is included only to simplify local testing, but any server Ubuntu 14.x could be used.  

To create a virtual machine with vagrant:

```
$ cd vagrant/ubuntu
$ vagrant up
```

The first execution of this downloads the Ubuntu image which can take 20 minutes or more. The ALA sample inventories (in the ansible/inventories/vagrant directory) refer to the VM as 'vagrant1' rather than the IP address. For this to work, you will need to add ```10.1.1.2  vagrant1 vagrant1.ala.org.au``` to your /etc/hosts file. Alternatively, you can edit the inventory file and replace 'vagrant1' with the IP address of your VM. 

Once ready you can ssh to your VM like so:

```
$ ssh vagrant@vagrant1
```
or 
```
$ ssh vagrant@10.1.1.2
```

with password ```vagrant```.

#### 2. Ansible

An [Ansible inventory file](http://docs.ansible.com/intro_inventory.html) is included that allows for running against a Vagrant configured VM (see ```inventories/vagrant/demo-vagrant```). Other inventories can easily be crafted to match other infrastructure.  

Note: any application deployed as part of a playbook requires the following two variables to be defined in the inventory: ```<applicationName>_hostname``` variable and ```<applicationName>_context_path```. See the readme file in the ansible directory for more information.

To run Ansible against your vagrant instance you need to locate the correct key file (e.g. the default insecure vagrant file if using the Vagrant config for testing):

```
$ cd ansible
$ ansible-playbook -i inventories/vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key -u vagrant
```


## Other playbooks  

### Vagrant

The ```inventories/vagrant/``` directory contains sample inventories for most playbooks that will work against a Ubuntu Vagrant virtual machine. To use these inventories, add an entry for ```vagrant1``` and ```vagrant1.ala.org.au``` to your hosts file, or edit the inventory file and replace the hostnames and URLs, then run

```
ansible-playbook --sudo --ask-sudo-pass -i inventories/vagrant/<inventoryFile> <playbook>.yml --private-key ~/.vagrant.d/insecure_private_key -u vagrant
```

The inventory files can easily be modified to work against other virtual machines or servers (e.g. Nectar or CSIRO) simply by modifying the server and host names appropriately.

## Notes for different environments (CSIRO/Nectar)

There are some minor differences for running these playbooks against Nectar VMs, CSIRO IM&T VMs and Vagrant VMs.
In each case you will need to create an inventory file that points to your VM(s).


For IM&T virtual machines:
```
$ ansible-playbook -i inventories/demo ala-demo.yml -u <CSIRO_IDENT> --ask-pass --ask-sudo-pass -s
```

For Nectar VMs:
```
$ ansible-playbook -i inventories/nectar-sandbox sandbox.yml --private-key <PATH_TO_YOUR_PEM_FILE> -u root
```
Note Nectar VMs will require an edit of the /etc/hosts file on the VM so that it recognises its own host name.

For Vagrant VMs:
```
$ ansible-playbook -i inventories/vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key  -u vagrant
```

For EC2 instances:
```
$ ansible-playbook -i inventories/solr-amazon solr-standalone.yml --private-key ~/.ssh/dmartin-amazon.pem -u ubuntu -s
```

## Required inventory properties
Most ALA playbooks will require at a minimum the following set of inventory properties:

* ```<applicationName>_hostname``` - The hostname portion of the url used to access the deployed service (e.g. 'ala.org.au' in the url http://ala.org.au/myApp)
* ```<applicationName>_context_path``` - The context path portion of the url used to access the deployed service (e.g. 'myApp' in the url http://ala.org.au/myApp). Note: this property should be blank for the context root, NOT a slash).
* ```auth_base_url``` - The HTTP*S* URL of the authentication server (e.g. https://auth.ala.org.au)
* ```auth_cas_url``` - The HTTP*S* URL of the CAS application on the authentication server (e.g. https://auth.ala.org.au/cas)
