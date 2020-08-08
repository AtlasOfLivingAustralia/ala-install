Ansible Role: Hadoop
===

[![Build Status](https://travis-ci.org/mm0/ansible-role-hadoop.svg?branch=master)](https://travis-ci.org/mm0/ansible-role-hadoop)

An Ansible role that installs and creates a hadoop file system

See Also: ansible-role-spark


Requirements
---

None 

Role Variables
---

Available variables are listed below, along with values defaults to AWS servers:

```yml
hadoop:
  version: 2.8.2
  hadoop_archive: hadoop-2.8.2.tar.gz
  hadoop_install_dir: hadoop-2.8.2
  data_dir: /var/hadoop/data
  name_dir: /var/hadoop/name
  temp_dir: /tmp/hadoop/hdfs/tmp
  download_location: https://archive.apache.org/dist/hadoop/common/
  user: "hdfs"               # the name of the (OS)user created for spark
  user_groups: []             # Optional list of (OS)groups the new spark user should belong to
  user_shell: "/bin/false"    # the hdfs user's default shell
```

Dependencies
---
- geerlinguy.java

Example Playbook
---

```yml
- hosts: nodes
  roles:
  - { role: ansible-role-hadoop}
```

License
---------------

BSD-2

Author Information
------------------

[Matt Margolin](mailto:matt.margolin@gmail.com)

[mm0](https://github.com/mm0) on github
