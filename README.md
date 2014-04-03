# ALA Portal Installation Scripts
An [Ansible](http://www.ansible.com/) based installation for ALA components for CentOS 6.x and Ubuntu 12.x.

## Vagrant
`vagrant` contains a configuration that can used with [VirtualBox](https://www.virtualbox.org/) to bring up a VH for deploying against.  
This is included only to simplify testing, but any server running CentOS 6.x could be used.  

Once this is done, you can bring up a VH using:
```
$ cd vagrant
$ vagrant up
```

The first execution of this downloads the CentOS image which can take 20 minutes or more. 

## Ansible

An inventory file is included that allows for running against a Vagrant configured VH.  Other inventories can easily be crafted.  

To run Ansible you need to locate the correct key file (e.g. the default insecure vagrant file if using the Vagrant config for testing):

```
$ cd ansible
$ ansible-playbook -i inventories/vagrant ala-demo.yml --private-key ~/.vagrant.d/insecure_private_key  -u root
```

The first execution of this downloads many large artifacts from the ALA sites and will likely take 30 minutes or more.  Subsequent executions do not perform this step.

For other non-local virtual machines, you'll need to supply an SSH password:

ansible-playbook -i inventories/images ala-demo.yml -vvvv -u mar759 --ask-pass --ask-sudo-pass