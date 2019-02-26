#!/bin/sh
bail() {
    echo $*
    exit 1
}
url=http://localhost:{{ jenkins_port | default('9192') }}
adminpwf="{{ jenkins_home }}/secrets/initialAdminPassword"
if [ -f "$adminpwf" ]; then
    pass=`cat "$adminpwf"` || bail "Can't get password"
else
    pass="{{ jenkins_admin_password }}"
fi
auth="{{ jenkins_admin_user }}:$pass"
command=create-job
jobs=`java -jar jenkins-cli.jar -s "$url" -auth "$auth" list-jobs` || bail "Can't get job list"
echo $jobs | grep -q "$*"
if [ $? -eq 0 ]; then
    command=update-job
fi
java -jar jenkins-cli.jar -s "$url" -auth "$auth" $command "$*" < "${1}.xml" || bail "Can't $command"
