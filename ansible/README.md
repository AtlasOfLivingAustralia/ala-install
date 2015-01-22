# Creating scripts for a new project
1. Run ```groovy AnsibleSkeleton <projectname> <options>``` where:
  1. ```<projectname>``` is the name of the application;
  2. ```<options>``` is a list of dependencies the project requires, in the order you wish them to appear in the scripts. E.g. 'mysql' if the project requires a MySQL database, 'properties' if the project has external configuration file(s).
  Example: ```groovy AnsibleSkeleton logger-service mysql properties tomcat``` would create a skeleton for the Logger Service, with a MySQL database, configuration files and Apache & Tomcat configuration/deployments.
2. This will create the following files/directories:
  - ```<projectname>-standalone.yml``` (playbook)
  - ```inventories/vagrant/<projectname>``` (inventory file that can be used for local Vagrant deployments)
  - ```roles/<projectname>/vars/main.yml``` (variables that do not change between environments, e.g. artifact id, version, etc)
  - ```roles/<projectname>/templates/<projectname>-config.properties``` (if 'properties' was included) (template configuration file)
  - ```roles/<projectname>/tasks/main.yml``` (task file listing all the steps required to build & deploy the application)
3. Edit the relevant files to fill in missing/placeholder variable names etc
4. Add any additional files or deployment tasks that are not supported by the skeleton


# Tomcat and Apache configuration
If your application requires a WAR file deployment then you use the common ```tomcat_deploy``` and ```apache_vhost``` roles. This will ensure a consistent approach to Tomcat and Apache configuration.

## How to use them

The easiest way to use these roles is to use parameterised includes in your main task file. E.g.

```
- include: ../../apache_vhost/tasks/main.yml context_path='{{ logger_context_path }}' hostname='{{ logger_hostname
  tags:
    - logger
    - apache_vhost
    - deploy
}}'

- include: ../../tomcat_deploy/tasks/main.yml war_url='{{ logger_war_url }}' context_path='{{ logger_context_path }}' hostname='{{ logger_hostname }}'
  tags:
    - logger
    - apache_vhost
    - deploy
```

The following parameters are required:

* ```context_path``` - the value of the ```<projectname>_context_path``` variable for your project
* ```hostname``` - the ```<projectname>_hostname``` variable for your project
* ```war_url``` - the URL of the WAR file to be downloaded and deployed (this should be from maven and is usually specified in the vars/main.yml file)

Note: the AnsibleSkeleton script will set all this up for you.

## What they do

These roles depend heavily on two inventory properties:

* ```<projectname>_context_path```
* ```<projectname>_hostname```

These variables tell the ```tomcat_deploy``` and ```apache_vhost``` roles how to configure your application using the following rules:

1. If ```<projectname>_context_path``` is blank or '/' then:
  1. Create an Apache Virtual Host for the ```<projectname>_hostname``` with proxy rules to forward all requests to Tomcat (i.e. ```ProxyPass / ajp://localhost:8009/```)
  2. Create a Tomcat Virtual Host for the ```<projectname>_hostname``` with the application deployed as ROOT.war (so it is the default context).
2. If ```<projectname>_context_path``` is NOT blank or '/' then:
  1. Create an Apache Virtual Host for the ```<projectname>_hostname``` with proxy rules to forward the ```<projectname>_context_path``` to the same context on Tomcat (i.e. ```ProxyPass /<projectname>_context_path  ajp://localhost:8009/<projectname>_context_path```)
      * If a virtual host already exists for ```<projectname>_hostname```, then it will be updated with the new ProxyPass rules.
   2. Deploy the application as ```<projectname>_context_path.war``` to the webapps/ directory on Tomcat
   3. Use this option when you have multiple context paths on the same hostname (e.g. my.host.name/app1 and my.host.name/app2).
3. If ```<projectname>_hostname``` contains a colon (':', indicating that there is a port number) OR is 'localhost' OR is '127.0.0.1' then 
   1. Do not create any Apache configuration
   2. Deploy the application as ```<projectname>_context_path.war``` to the webapps/ directory on Tomcat

## Other optional parameters

There are several other properties that can be specified to perform certain actions:

1. ```proxy_root_context_to``` - this property is often used by the 'hub' deployments and allows the root context to be proxied to a different context path on Tomcat. For an example, see the appd.yml playbook.
2. ```additional_proxy_pass``` - this property is used to create additional proxy rules in the Apache virtual host. It is a list property with items in the format ```{ src: <from>, dest: <to> }```
For example:
```
additional_proxy_pass:
  - { src: "/biocache-media", dest: "!" }
```
will create 
```
ProxyPass /biocache-media   !
```

## Examples

1. To deploy the logger-service to ```logger.ala.org.au```:
  1. ```logger_context_path =```
  2. ```logger_hostname = logger.ala.org.au```
2. To deploy the logger service to ```ala.org.au/logger```:
  1. ```logger_context_path = logger```
  2. ```logger_hostname = ala.org.au```

(these values go in the inventory file to be used when you run the playbook)
