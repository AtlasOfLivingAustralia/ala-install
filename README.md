# ALA Installation Scripts
This project contains [Ansible](http://www.ansible.com/) playbooks for setting up ALA components on CentOS 6.x and Ubuntu 12.x machines.
This project includes a playbook for setting up the [ALA demo ](http://ala-demo.gbif.org).

## Setup the ALA demo

Below are some instructions for setting up the [ALA demo](http://ala-demo.gbif.org) with Ansible & Vagrant on your local machine.

#### 1. Vagrant
[Vagrant](http://www.vagrantup.com) can be used to test ansible playbooks on your local machine. To use this, you will need to install
[VirtualBox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com).
```vagrant/centos``` and ```vagrant/ubuntu``` contain configurations that can used with [VirtualBox](https://www.virtualbox.org/) to bring up a VH for deploying against.  
This is included only to simplify local testing, but any server running CentOS 6.x or Ubuntu 12.x could be used.  

To create a virtual machine with vagrant:

```
$ cd vagrant/centos
$ vagrant up
```

The first execution of this downloads the CentOS image which can take 20 minutes or more. Once ready you can ssh to your VM like so:

```
$ ssh vagrant@10.1.1.2
```

with password ```vagrant```.

#### 2. Ansible

An [Ansible inventory file](http://docs.ansible.com/intro_inventory.html) is included that allows for running against a Vagrant configured VH (see ```inventories/vagrant```). Other inventories can easily be crafted to match other infrastructure.  

To run Ansible against your vagrant instance you need to locate the correct key file (e.g. the default insecure vagrant file if using the Vagrant config for testing):

```
$ cd ansible
$ ansible-playbook -i inventories/vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key  -u root
```


## Other playbooks  


### Standalone Biocache Hub on Nectar

There is a template inventory in ```inventories/ala-hub-nectar```. To use this playbook for your VM, create a copy of ```inventories/sandbox```
and change the references to point to the IP/DNS of your VM. Then point to this inventory with the ```-i``` parameter when running the playbook.

```
$ ansible-playbook -i inventories/ala-hub-nectar biocache-hub.yml --private-key <PATH_TO_YOUR_PEM_FILE> -u root 
```

### Sandbox on Nectar

```inventories/sandbox``` contains an inventory for the sandbox. To use this playbook for your VM, create a copy of ```inventories/sandbox```
and change the references to point to the IP/DNS of your VM. Then point to this inventory with the ```-i``` parameter when running the playbook.

```
$ ansible-playbook -i inventories/sandbox sandbox.yml --private-key <PATH_TO_YOUR_PEM_FILE> -u root 
```

### Image service on Nectar

```inventories/images``` contains an inventory for the image-service. To use this playbook for your VM, create a copy of ```inventories/images```
and change the references to point to the IP/DNS of your VM. Then point to this inventory with the ```-i``` parameter when running the playbook.

```
$ ansible-playbook -i inventories/images image-service.yml --private-key <PATH_TO_YOUR_PEM_FILE> -u root 
```


## Notes for different environments (CSIRO/Nectar)

There are some minor differences for running these playbooks against Nectar VMs, CSIRO IM&T VMs and Vagrant VMs.
In each case you will need to create an inventory file that points to your VM(s).


For IM&T virtual machines:
```
$ ansible-playbook -i inventories/demo ala-demo.yml -u <CSIRO_IDENT> --ask-pass --ask-sudo-pass
```

For Nectar VMs:
```
$ ansible-playbook -i inventories/nectar-sandbox sandbox.yml --private-key <PATH_TO_YOUR_PEM_FILE> -u root
```
Note Nectar VMs will require an edit of the /etc/hosts file on the VM so that it recognises its own host name.

For Vagrant VMs:
```
$ ansible-playbook -i inventories/vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key  -u root
```

For EC2 instances:
```
$ ansible-playbook -i inventories/solr-amazon solr-standalone.yml --private-key ~/.ssh/dmartin-amazon.pem -u ubuntu -s
```

