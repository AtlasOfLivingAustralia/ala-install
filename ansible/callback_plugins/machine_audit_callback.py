# callback to store server audit data

# ===== READ ME =====
# This has to be installed as a callback plugin to your Ansible setup.
# The location of your callback plugins directory is set in your Ansible
# configuration as the value of "callback_plugins".  The default location is
# /usr/share/ansible_plugins/callback_plugins but this can be changed.
#
# Copy this file to your callback plugins directory.  You may have to create
# the directory if it doesn't exist.


import os
import time
import json
import humanize

TIME_FORMAT='%Y-%m-%d-%H-%M'
outputdir = "machine_audit"


def prepfile():
  # ensure that the output directory is present
  if not os.path.exists(outputdir):
    os.makedirs(outputdir)
  outputfilename = 'machine_audit.csv'
  outputline = 'Hostname,Reachable,IPv4 address,IPv4 network,Data centre,vCPUs,'
  outputline += 'RAM total GB,RAM free GB,mount sizes,total storage,used storage,'
  outputline += 'swap GB,Linux distro,distro version,Tomcat dir/s,Tomcat webapps,'
  outputline += 'Tomcat version,Java version,Java vendor,MySQL,Postgres,'
  outputline += 'Cassandra,MongoDB'
  outputline += '\n'
  with open(outputdir + "/" + outputfilename, 'w') as of:
    of.write(outputline + "\n")


def logfail(host, data, failstring):
  if data is None or isinstance(data, basestring):
    outputfilename = 'machine_audit.csv'
  else:
    facts = data.get('ansible_facts', None)
    outputfilename = facts.get('outputfile', 'machine_audit.csv')
  outputline = "{hname},{fstring}".format(hname=host,fstring=failstring)
  try:
    with open(outputdir + "/" + outputfilename, 'a') as of:
      of.write(outputline + "\n")
  except:
    pass

def log(host, data):
  if type(data) == dict:
    invocation = data.pop('invocation', None)
    if invocation.get('module_name', None) != 'machine_audit':
      return

  # debug
  # print "ALL DATA: " + json.dumps(data)

  facts = data.get('ansible_facts', None)

  outputfilename = facts.get('outputfile', 'machine_audit.csv')

  try:
    # gather the useful data

    # hostname
    outputline = "{data},".format(data=host)
    # if facts.get('ansible_fqdn', None) == 'localhost':
    #   outputline = "{data},".format(data=facts.get('ansible_hostname', None))
    # else:
    #   outputline = "{data},".format(data=facts.get('ansible_fqdn', None))

    # reachable
    outputline += "OK,"
    # IP
    outputline += "{data},".format(data=facts.get('ansible_default_ipv4', None).get('address', None))
    # network
    thisnetwork = facts.get('ansible_default_ipv4', None).get('network', None)
    outputline += "{data},".format(data=thisnetwork)
    # Data centre (Melbourne/Canberra)
    datacentre = "???"
    if thisnetwork in ('138.194.80.0', '138.194.85.0', '138.194.104.0', '150.229.66.0'):
      datacentre = "Melbourne"
    elif thisnetwork in ('150.229.2.0', '152.83.240.0', '152.83.3.0', '152.83.8.0'):
      datacentre = "Canberra"
    outputline += "{data},".format(data=datacentre)
    # The following IP addresses are based in Melbourne:
    # 138.194.80.0
    # 138.194.85.0
    # 138.194.104.0
    # 150.229.66.0
    #
    # The following IP addresses are based in Canberra:
    # 150.229.2.0
    # 152.83.240.0
    # 152.83.3.0
    # 152.83.8.0
    #
    # Note that the network 150.229.0.0 is broad and encompasses many subnets which are based around the country.


    # CPU allocation
    outputline += "{data},".format(data=facts.get('ansible_processor_vcpus', None))
    # RAM allocation in GB
    totalram = float(facts.get('ansible_memtotal_mb', 0)) / 1024
    outputline += "{0:.2f},".format(totalram)
    # RAM free in GB
    ramfree = float(facts.get('ansible_memfree_mb', 0)) / 1024
    outputline += "{0:.2f},".format(ramfree)

    # Disk partitions including current usage
    totalstorage = 0
    availstorage = 0
    for thismount in facts.get('ansible_mounts'):
      totalstorage += float(thismount.get('size_total'))
      availstorage += float(thismount.get('size_available'))
      totalsize = humanize.naturalsize(float(thismount.get('size_total')))
      availsize = humanize.naturalsize(float(thismount.get('size_available')))
      outputline += "{dname}:{total}({avail} avail) ".format(dname=thismount.get('device'),total=totalsize,avail=availsize)
    outputline += ","
    outputline += "{storagetotal},".format(storagetotal=humanize.naturalsize(totalstorage))
    outputline += "{0:.1f}%,".format((1 - (availstorage/totalstorage)) * 100)

    # Swap space in GB
    swaptotal = float(facts.get('ansible_swaptotal_mb', 0)) / 1024
    outputline += "{0:.2f},".format(swaptotal)
    # Linux distro
    outputline += "{data},".format(data=facts.get('ansible_distribution', None))
    # Linux distro version
    outputline += "{data},".format(data=facts.get('ansible_distribution_version', None))

    machine_audit = data.get('machine_audit', None)
    if machine_audit is not None:
      # webapp dir/s
      tomcatdirs = machine_audit.get('tomcat_dirs', None)
      if tomcatdirs is not None:
        for thistomcat in tomcatdirs:
          outputline += "{data} ".format(data=thistomcat)
      outputline += ","
      # Webapps install
      tomcatapps = machine_audit.get('tomcat_apps', None)
      if tomcatapps is not None:
        for thistomcat in tomcatapps:
          outputline += "{data} ".format(data=thistomcat)
      outputline += ","
      # Tomcat version
      tomcatversion = machine_audit.get('tomcat_version', None)
      if tomcatversion is not None:
          outputline += "{data}".format(data=tomcatversion)
      outputline += ","
      # Java version
      javaversion = machine_audit.get('java_version', None)
      if javaversion is not None:
          outputline += "{data}".format(data=javaversion)
      outputline += ","
      # Java vendor (variant will be Oracle, Sun, or the dreaded IBM JDK)
      javavendor = machine_audit.get('java_vendor', None)
      if javavendor is not None:
          outputline += "{data}".format(data=javavendor)
      outputline += ","
      # MySQL
      mysqlver = machine_audit.get('mysql_version', None)
      if mysqlver is not None:
          outputline += "{data}".format(data=mysqlver)
      outputline += ","
      # Postgres
      postgresver = machine_audit.get('postgres_version', None)
      if postgresver is not None:
          outputline += "{data}".format(data=postgresver)
      outputline += ","
      # Cassandra
      cassver = machine_audit.get('cassandra_version', None)
      if cassver is not None:
          outputline += "{data}".format(data=cassver)
      outputline += ","
      # MongoDB
      mongover = machine_audit.get('mongodb_version', None)
      if mongover is not None:
          outputline += "{data}".format(data=mongover)
      outputline += ","

      # Additional running processes (ActiveMQ, Jenkins)
      # RAM allocation for Tomcat instances

      # Open ports

    # write the data
    # print "callback filename is {fname}".format(fname=outputfilename)
    # print "callback output line is {oline}".format(oline=outputline)
    with open(outputdir + "/" + outputfilename, 'a') as of:
      of.write(outputline + "\n")
  except:
    pass

class CallbackModule(object):
  def on_any(self, *args, **kwargs):
    pass
  def runner_on_failed(self, host, res, ignore_errors=False):
    pass
  def runner_on_ok(self, host, res):
    log(host, res)
  def runner_on_skipped(self, host, item=None):
    logfail(host, res, 'Host skipped')
  def runner_on_unreachable(self, host, res):
    logfail(host, res, 'Unreachable')
  def runner_on_no_hosts(self):
    pass
  def runner_on_async_poll(self, host, res, jid, clock):
    pass
  def runner_on_async_ok(self, host, res, jid):
    pass
  def runner_on_async_failed(self, host, res, jid):
    pass
  def playbook_on_start(self):
    prepfile()
  def playbook_on_notify(self, host, handler):
    pass
  def playbook_on_no_hosts_matched(self):
    pass
  def playbook_on_no_hosts_remaining(self):
    pass
  def playbook_on_task_start(self, name, is_conditional):
    pass
  def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
    pass
  def playbook_on_setup(self):
    pass
  def playbook_on_import_for_host(self, host, imported_file):
    pass
  def playbook_on_not_import_for_host(self, host, missing_file):
    pass
  def playbook_on_play_start(self, name):
    pass
  def playbook_on_stats(self, stats):
    pass
