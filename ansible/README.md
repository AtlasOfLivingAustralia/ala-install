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

1. If ```<projectname>_hostname``` is not empty, not localhost, not the loopback and does not contain a colon:
    1. If ```<projectname>_context_path``` is blank or "/":
        1. Create an Apache Virtual Host for the ```<projectname>_hostname``` with proxy rules to forward the root context to Tomcat (i.e. ```ProxyPass / ajp://localhost:8009/```)
        1. Create a Tomcat Virtual Host for the ```<projectname>_hostname``` with the application deployed as ROOT.war (so it is the default context).
    1. If ```<projectname>_context_path``` is NOT blank or "/"
        1. Create an Apache Virtual Host for the ```<projectname>_hostname``` with proxy rules to forward the ```<projectname>_context_path``` context to Tomcat (i.e. ```ProxyPass /<context> ajp://localhost:8009/<conttext>```)
        1. Create a Tomcat Virtual Host for the ```<projectname>_hostname``` with the application deployed as ```<projectname>_context_path.war```.
1. If ```<projectname>_hostname``` is empty, localhost, the loopback or contains a colon:
    1. Do not create any Apache configuration
    1. Do not create a Tomcat virtual host
    1. If ```<projectname>_context_path``` is blank or "/":
        1. Deploy the application as ROOT.war to the webapps/ directory on Tomcat
    1. If ```<projectname>_context_path``` is NOT blank or "/":
        1. Deploy the application as ```<projectname>_context_path.war``` to the webapps/ directory on Tomcat

NOTES:
1. These steps are non-destructive, so if the tomcat or apache vhosts already exists then they will be updated.
1. You cannot have multiple applications as the root context, so if your playbook/inventory uses ```<projectname>_context_path=``` for multiple applications then you will have a problem.

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
3. ```log_filename``` - the filename of the application's log file, so that the tomcat_deploy role can back it up. If not provided, the war_filename will be used. Do not include the file extension.

The existing WAR file and log file will be backed up before the new WAR is deployed.

### HTTPS Configuration

HTTPS can be enabled for your playbook by specifying

```
ssl = true
```

in your inventory. 

There are two options for installing HTTPS key/cert/etc files on your server:

1. Copy local files to the server; or
1. Manage them on the server with a tool like SSL Mate (this is the default).

ALA uses option 2.

Use the following parameters if you need to copy local files to your server:

1. ```ssl = true``` - this enables HTTPS
1. ```copy_https_certs_from_local = true``` - this enables the copy option
1. ```ssl_certificate_server_dir = /path/to/cert/dir/on/server``` - this is the location on the server for your certificate and key files
1. ```ssl_certificate_local_dir = /LOCAL/path/to/ssl/files``` - this is the LOCAL file path to the HTTPS configuration files (key, cert, chain) that need to be deployed to the server
1. ```ssl_cert_file = filename``` - this is the name of the HTTPS certificate file, used to copy the file to the server (into ssl\_certificate\_server\_dir) and to set the ```SSLCertificateFile``` directive (to ssl\_certificate\_server\_dir/ssl\_cert\_file).
1. ```ssl_key_file = filename``` - this is the name of the HTTPS key file, used to copy the file to the server (into ssl\_certificate\_server\_dir) and to set the ```SSLCertificateKeyFile``` directive (to ssl\_certificate\_server\_dir/ssl\_key\_file).
1. ```ssl_chain_file = filename``` - this is the name of the HTTPS certificate chain file, used to copy the file to the server (into ssl\_certificate\_server\_dir) and to set the ```SSLCertificateChainFile``` directive (to ssl\_certificate\_server\_dir/ssl\_chain\_file).

## Examples

1. To deploy the logger-service to ```logger.ala.org.au```:
  1. ```logger_context_path =```
  2. ```logger_hostname = logger.ala.org.au```
2. To deploy the logger service to ```ala.org.au/logger```:
  1. ```logger_context_path = logger```
  2. ```logger_hostname = ala.org.au```

(these values go in the inventory file to be used when you run the playbook)

# External Configuration Files
Most ALA applications require an external configuration properties file. This file is typically deployed via an ansible template so that environment-specific values (such as database connections and URLs to other services) can be substituted at deploy time.

When writing a new Ansible script, ensure that your application's configuration properties file has been moved (do NOT leave a copy in the application's GIT repository) to the templates directory for the application role, and replace ALL URLs and other environment-specific values with ansible variables. *Note: this must include the CAS server URLs.*

This will ensure that your application can be safely deployed to a non-production or non-ALA environment.

The AnsibleSkeleton script will create a skeleton properties file for your application, with appropriate variables for the auth servers (```auth_base_url``` and ```auth_cas_url```).

*Auth URLs MUST be accessed via HTTPS.*

# Sample Inventories
The inventories/vagrant directory contains inventories for deploying applications to a vagrant instance.

For these inventories to work, you will need to have a Ubuntu 14.04 vagrant VM running, with the IP address mapped to ```vagrant1``` AND ```vagrant1.ala.org.au``` in your /etc/hosts files. The inventories refer to the host as 'vagrant1', and the URLs for the applications will be 'vagrant1.ala.org.au/something`.

# Database backups
The role ```role/db-backup``` can be included in your playbook to backup a database instance during each deployment. This role currently supports MongoDB, MySQL and Postgres. The role defines a *db_backup* tag.

This role will export the database to a .gz file called db\_[timestamp].gz in a directory you specify (defaults to /data).

To use this role, add the following to your playbook _before_ your application deployment:

``` - { role: db-backup, db: "mongo|mysql|postgres" } ```.

You will also need to specify the following variables in your inventory file:

|Database|Option|Mandatory|Default|Description|
|--------|------|---------|-------|-----------|
|All|backup\_dir|No|/data|The directory to save the backup file to|
|MongoDB|db\_hostname|No|localhost|The hostname to use when connecting to the database|
| |db\_port|No|27017|The port to use when connecting to the database|
|MySQL|db\_user|Yes|none|The user to connect as|
| |db\_password|Yes|none|The user's password|
| |db\_name|Yes|none|The name of the database schema to backup|
| |db\_host|No|localhost|The hostname to use when connecting to the database|
| |db\_port|No|3306|The port to use when connecting to the database|
|Postgres|db\_user|Yes|none|The user to connect as|
| |db\_name|Yes|none|The name of the database schema to backup|

* NOTE: There are some current limitations with the postgres support due to the way it handles authentication. The current implementation only supports postgres instances running on localhost as the postgres user.

To skip the database backup step during your deployment, add the following to your ansible-playbook command: ``` --skip-tags backup```.
