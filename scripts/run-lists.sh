cd /Users/mar759/dev/ala-install/vagrant/ubuntu-xenial
vagrant destroy -f
vagrant up
ansible-playbook --private-key ~/.vagrant.d/insecure_private_key -vvvv -u vagrant -s -i /Users/mar759/dev/ala-install/ansible/inventories/vagrant/species-list-vagrant /Users/mar759/dev/ala-install/ansible/species-list-standalone.yml
