#!/usr/bin/python
# -*- coding: utf-8 -*-

# Written by Matt Andrews for Atlas of Living Australia (ala.org.au)
# as a custom Ansible module used to gather additional facts about
# servers.  This is a fork of the core Ansible "setup" module.

import os

DOCUMENTATION = '''
---
module: machine_audit
version_added: historical
short_description: Gathers custom (Java oriented) facts about remote hosts
description:
     - This is a custom module which is a fork of the core 'setup' module. It
      includes all the standard 'setup' fact-gathering, and also gathers more
      facts about Tomcat web apps, Java virtual machines, etc.
author: Matt Andrews (Michael DeHaan wrote the core setup module)
'''

EXAMPLES = """
# Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
ansible all -m machine_audit --tree /tmp/facts

"""


def run_setup(module):

    setup_options = dict(module_setup=True)
    facts = ansible_facts(module)

    for (k, v) in facts.items():
        setup_options["ansible_%s" % k.replace('-', '_')] = v

    # Look for the path to the facter and ohai binary and set
    # the variable to that path.
    facter_path = module.get_bin_path('facter')
    ohai_path = module.get_bin_path('ohai')

    # if facter is installed, and we can use --json because
    # ruby-json is ALSO installed, include facter data in the JSON
    if facter_path is not None:
        rc, out, err = module.run_command(facter_path + " --puppet --json")
        facter = True
        try:
            facter_ds = json.loads(out)
        except:
            facter = False
        if facter:
            for (k,v) in facter_ds.items():
                setup_options["facter_%s" % k] = v

    # ditto for ohai
    if ohai_path is not None:
        rc, out, err = module.run_command(ohai_path)
        ohai = True
        try:
            ohai_ds = json.loads(out)
        except:
            ohai = False
        if ohai:
            for (k,v) in ohai_ds.items():
                k2 = "ohai_%s" % k.replace('-', '_')
                setup_options[k2] = v

    setup_result = { 'ansible_facts': {} }

    for (k,v) in setup_options.items():
        if module.params['filter'] == '*' or fnmatch.fnmatch(k, module.params['filter']):
            setup_result['ansible_facts'][k] = v

    # hack to keep --verbose from showing all the setup module results
    setup_result['verbose_override'] = True

    return setup_result


def get_custom_facts(module, data):
    data['machine_audit'] = dict()

    # Tomcat webapps
    tomcat_apps_array = []
    tomcat_dirs_present = []
    tomcat_dirs = ['/var/lib/tomcat7/webapps','/usr/share/tomcat6/webapps','/usr/local/tomcat/webapps']
    for thistomcatdir in tomcat_dirs:
        if os.path.exists(thistomcatdir):
          tomcat_dirs_present.append(thistomcatdir)
          rc, out, err = module.run_command("ls -1 " + thistomcatdir)
          if rc == 0:
              for line in out.split('\n'):
                tomcat_apps_array.append(line)
    data['machine_audit']['tomcat_dirs'] = tomcat_dirs_present
    data['machine_audit']['tomcat_apps'] = tomcat_apps_array

    # Tomcat version
    if len(tomcat_dirs_present) > 0:
      if os.path.exists('/usr/share/tomcat7/bin/version.sh'):
        rc, out, err = module.run_command('/usr/share/tomcat7/bin/version.sh')
      elif os.path.exists('/usr/share/tomcat6/bin/version.sh'):
        rc, out, err = module.run_command('/usr/share/tomcat6/bin/version.sh')
      else:
        # no version.sh so try ServerInfo
        # remove /webapps from webapp dir path to get root dir
        tomcat_root_dir = tomcat_dirs_present[0][0:-8]
        rc, out, err = module.run_command("java -cp {rdir}/lib/catalina.jar org.apache.catalina.util.ServerInfo".format(rdir=tomcat_root_dir))
      if rc == 0:
          for line in out.split('\n'):
              if 'Server version' in line:
                  # Server version: Apache Tomcat/6.0.24
                  data['machine_audit']['tomcat_version'] = line[16:]
              elif 'JVM Version' in line:
                  # JVM Version:    1.7.0_72-b14
                  # ...but in IBM it looks like this:
                  # JVM Version:    pxa6460sr8fp1-20100624_01 (SR8 FP1)
                  try:
                      float(line[0:2])
                      data['machine_audit']['java_version'] = line[16:]
                  except ValueError:
                      pass

              elif 'JVM Vendor' in line:
                  # JVM Vendor:     Oracle Corporation
                  data['machine_audit']['java_vendor'] = line[16:]

    # RAM allocation for Tomcat instances


    if 'java_version' not in data['machine_audit']:
      # Java version installed
      rc, out, err = module.run_command("which java")
      # if Java is installed, get the version
      if rc == 0:
        rc, out, err = module.run_command("java -version")
        # note java version output goes to stderr (!)
        rawjavaversionlines = err.split('\n')
        if len(rawjavaversionlines) > 0 and len(rawjavaversionlines[0]) > 0 and '\"' in rawjavaversionlines[0]:
          data['machine_audit']['java_version'] = rawjavaversionlines[0].split('\"')[1]
        # Java vendor (variant will be Oracle 6, 7 or the dreaded IBM JDK)
        if 'IBM ' in err:
          data['machine_audit']['java_vendor'] = 'IBM'
    # java -XshowSettings:properties -version
    if 'java_vendor' not in data['machine_audit']:
      rc, out, err = module.run_command("which java")
      if rc == 0:
        rc, out, err = module.run_command("java -XshowSettings:properties -version")
        # note java version output goes to stderr (!)
        rawjavaversionlines = err.split('\n')
        for thisline in rawjavaversionlines:
          if 'java.vm.vendor' in thisline:
            # java.vm.vendor = Oracle Corporation
            data['machine_audit']['java_vendor'] = thisline.split('=')[1][1:]
    # If we still don't have the vendor, throw in a guess
    if 'java_vendor' not in data['machine_audit'] and 'java_version' in data['machine_audit']:
      javaminorversion = data['machine_audit']['java_version'].split('.')[1]
      if javaminorversion == '6':
         data['machine_audit']['java_vendor'] = 'Sun?'
      elif javaminorversion == '7':
         data['machine_audit']['java_vendor'] = 'Oracle?'

    # DBs installed (MySQL, Postgres, Cassandra, MongoDB)
    # MySQL
    rc, out, err = module.run_command("which mysql")
    if rc == 0:
      # we appear to have MySQL installed
      rc, out, err = module.run_command("mysql --version")
      data['machine_audit']['mysql_version'] = out.split('\n')[0].split(',')[0]

    # Postgres
    rc, out, err = module.run_command("which psql")
    if rc == 0:
      # we appear to have Postgres installed
      rc, out, err = module.run_command("psql --version")
      data['machine_audit']['postgres_version'] = out.split('\n')[0].split(',')[0]

    # Cassandra
    rc, out, err = module.run_command("which cqlsh")
    if rc == 0:
      # we appear to have Cassandra installed
      rc, out, err = module.run_command("cqlsh --version")
      data['machine_audit']['cassandra_version'] = out.split('\n')[0].split(',')[0]

    # MongoDB
    rc, out, err = module.run_command("which mongod")
    if rc == 0:
      # we appear to have MongoDB installed
      rc, out, err = module.run_command("mongod --version")
      data['machine_audit']['mongodb_version'] = out.split('\n')[0].split(',')[0]

    # solr: ala-bie1 (running)

    # Additional running processes (ActiveMQ, Jenkins)

    # Open ports

    return data


def main():
    global module
    module = AnsibleModule(
        argument_spec = dict(
            filter=dict(default="*", required=False),
            fact_path=dict(default='/etc/ansible/facts.d', required=False),
        ),
        supports_check_mode = True,
    )
    data = run_setup(module)
    data = get_custom_facts(module, data)
    module.exit_json(**data)

# import module snippets

from ansible.module_utils.basic import *

from ansible.module_utils.facts import *

main()
