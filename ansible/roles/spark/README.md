Ansible Role: Spark
===

[![Build Status](https://travis-ci.org/mm0/ansible-role-spark.svg?branch=master)](https://travis-ci.org/mm0/ansible-role-spark)

An Ansible role that installs and configures Spark

See Also: ansible-role-hadoop


Requirements
---

None 

Role Variables
---

Available variables are listed below:

```yml
spark:
  version: 2.4.0
  hadoop_version: 2.9.2
  working_dir: /tmp/spark/data
  master_port: 7077
  worker_work_port: 65000
  master_ui_port: 8080
  worker_ui_port: 8085
  download_location: https://archive.apache.org/dist/spark/
  user: "spark"               # the name of the (OS)user created for spark
  user_groups: []             # Optional list of (OS)groups the new spark user should belong to
  user_shell: "/bin/false"    # the spark user's default shell

  env_extras: {}
  defaults_extras: {}
```

Dependencies
---

None 

Example Playbook
---

```yml
- hosts: nodes
  roles:
  - { role: mm0.spark }
```

License
---------------

BSD-2

Author Information
------------------

[Matt Margolin](mailto:matt.margolin@gmail.com)

[mm0](https://github.com/mm0) on github
