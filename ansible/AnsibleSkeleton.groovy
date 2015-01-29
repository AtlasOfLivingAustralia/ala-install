class AnsibleSkeleton {

    static File playbook
    static File tasks
    static File vars
    static File properties
    static List files

    static String appName
    static String appNameVar

    static main(args) {
        if (args.size() == 0 || args[0] == "?") {
            println "AnsibleSkeleton <application-name> <list of items to be added in order>"
            println "e.g. AnsibleSkeleton logger-service properties mysql tomcat"
            return
        }

        files = []

        appName = args[0]
        appNameVar = appName.replace("-", "_")

        new File("roles/${appName}").deleteDir()
        new File("roles/${appName}/tasks").mkdirs()
        new File("roles/${appName}/templates").mkdirs()
        new File("roles/${appName}/vars").mkdirs()

        if (args.contains("properties")) {
            properties = new File("roles/${appName}/templates/${appName}-config.properties")
            files << properties
        }
        tasks = new File("roles/${appName}/tasks/main.yml")
        files << tasks
        vars = new File("roles/${appName}/vars/main.yml")
        files << vars
        write(tasks, """\
                        - include: ../../common/tasks/setfacts.yml
                          tags:
                            - ${appName}
                     """.stripIndent(), false)

        playbook = new File("${appName}-standalone.yml")
        files << playbook
        write(playbook, "- hosts: ${appName}\n  roles:\n    - common\n    - java", false)

        args.drop(1).each {
            try {
                "${it}"()
            }
            catch (MissingMethodException e) {
                println "I don't know what to do with ${it}....skipping it"
            }
        }

        write(playbook, "\n    - ${appName}")

        inventory(args)
        vars()

        println "\n\nDone!!\nFiles created:"
        files.each { println " - ${it}" }

        println "Finished creating skeleton...you still need to check variable names and add anything not covered by " +
                "the skeleton."
    }

    static vars() {
        println "  - Creating vars file..."
        write(vars, "# assets\n" +
                "version: \"???\"\n" +
                "artifactId: \"${appName}\"\n" +
                "classifier: ''\n" +
                "groupId: \"au.org.ala\"\n" +
                "packaging: \"war\"\n" +
                "${appNameVar}_war_url: \"{{maven_repo_ws_url}}\"", false)
    }

    static properties() {
        println "  - Adding config properties file stuff..."

        write(properties, """
                    #
                    # CAS Config
                    #
                    casProperties=casServerLoginUrl,serverName,centralServer,casServerName,uriFilterPattern,uriExclusionFilter,authenticateOnlyIfLoggedInFilterPattern,casServerLoginUrlPrefix,gateway,casServerUrlPrefix,contextPath
                    serverName=http://{{ ${appNameVar}_hostname }}
                    contextPath={{ ${appNameVar}_context_path }}
                    grails.serverURL=http://{{ ${appNameVar}_hostname }}{{ ${appNameVar}_context_path }}
                    casServerName=https://auth.ala.org.au
                    uriExclusionFilterPattern=/images.*,/css.*,/js.*,/less.*
                    casServerLoginUrl=https://auth.ala.org.au/cas/login
                    gateway=false
                    casServerUrlPrefix=https://auth.ala.org.au/cas
                    security.cas.logoutUrl=https://auth.ala.org.au/cas/logout
                    authenticateOnlyIfLoggedInFilterPattern=???
                    auth.admin_role=ROLE_ADMIN
                    uriFilterPattern=/admin, /admin/.*
                    """.stripIndent())

        write(tasks, """
                    #
                    # External configuration properties file
                    #
                    - name: ensure target directories exist [data subdirectories etc.]
                      file: path={{item}} state=directory owner={{tomcat_user}} group={{tomcat_user}}
                      with_items:
                        - "{{data_dir}}/${appName}/config"
                      tags:
                        - properties
                        - ${appName}

                    - name: copy all config.properties
                      template: src=${appName}-config.properties dest={{data_dir}}/${appName}/config/${appName}-config.properties
                      tags:
                        - properties
                        - ${appName}

                    - name: set data ownership
                      file: path={{data_dir}}/${appName} owner={{tomcat_user}} group={{tomcat_user}} recurse=true
                      notify:
                        - restart tomcat
                      tags:
                        - properties
                        - ${appName}
                    """.stripIndent())


    }

    static mysql() {
        println "  - Adding mysql stuff..."

        write(playbook, "\n    - mysql")

        write(tasks, """
                    #
                    # Database configuration items
                    #
                    - name: create database
                      mysql_db: name={{${appNameVar}_db_name}} state=present
                      register: dbschema
                      tags:
                        - db
                        - ${appName}

                    - name: create DB user
                      mysql_user: name={{${appNameVar}_db_username}} password={{ ${appNameVar}_db_password}} priv=*.*:ALL state=present
                      register: dbuser
                      tags:
                        - db
                        - ${appName}
                    """.stripIndent())

        write(properties, """
                    #
                    # Datasource configuration
                    #
                    dataSource.driverClassName=com.mysql.jdbc.Driver
                    dataSource.url=jdbc:mysql://{{ ${appNameVar}_db_hostname }}/{{ ${appNameVar}_db_name }}?autoReconnect=true&connectTimeout=0
                    dataSource.username={{ ${appNameVar}_db_username }}
                    dataSource.password={{ ${appNameVar}_db_password }}
                    """.stripIndent())
    }

    static postgresql() {
        println "  - Adding postgresql stuff..."

        write(playbook, "\n    - postgresql")

        write(tasks, """
                    #
                    # Database configuration items
                    #
                    - name: create database
                      postgresql_db: name={{${appNameVar}_db_name}} state=present
                      sudo_user: postgres
                      sudo: True
                      register: dbschema
                      tags:
                        - db
                        - ${appName}

                    - name: create database user
                      postgresql_user: db={{${appNameVar}_db_name}} name={{${appNameVar}_db_username}} password={{${appNameVar}_db_password}} priv=ALL state=present
                      sudo_user: postgres
                      sudo: True
                      register: dbuser
                      tags:
                        - db
                        - ${appName}
                    """.stripIndent())

        write(properties, """
                    #
                    # Datasource configuration
                    #
                    dataSource.driverClassName=org.postgresql.Driver
                    dataSource.url=jdbc:postgresql://{{ ${appNameVar}_db_hostname }}/{{ ${appNameVar}_db_name }}
                    dataSource.username={{ ${appNameVar}_db_username }}
                    dataSource.password={{ ${appNameVar}_db_password }}
                    """.stripIndent())
    }

    static tomcat() {
        println "  - Adding tomcat & apache stuff..."
        write(playbook, "\n    - apache")
        write(playbook, "\n    - tomcat")

        write(tasks, """
                #
                # WAR file deployment and virtual host configuration
                #
                - include: ../../apache_vhost/tasks/main.yml context_path='{{ ${appNameVar}_context_path }}' hostname='{{ ${appNameVar}_hostname }}'
                  tags:
                    - deploy
                    - apache_vhost
                    - ${appName}

                - include: ../../tomcat_deploy/tasks/main.yml war_url='{{ ${appNameVar}_war_url }}' context_path='{{${appNameVar}_context_path}}' hostname='{{ ${appNameVar}_hostname }}'
                  tags:
                    - deploy
                    - tomcat_vhost
                    - ${appName}
                """.stripIndent())

    }

    static inventory(args) {
        println "  - Creating skeleton inventory file for vagrant..."

        File inventoryVagrant = new File("inventories/vagrant/${appName}-vagrant")
        files << inventoryVagrant

            write(inventoryVagrant, """\
                [${appName}]
                vagrant1

                [${appName}:vars]
                is_vagrant=true
                local_repo_dir=~/.ala
                data_dir=/data

                ${appNameVar}_hostname=vagrant1.ala.org.au
                ${appNameVar}_context_path=/???
                ${appNameVar}_base_url=http://vagrant1.ala.org.au
                ${appNameVar}_url=http://vagrant1.ala.org.au/???
                """.stripIndent(), false)

            if (args.contains("mysql") || args.contains("postgresql")) {
                write(inventoryVagrant, """
                        ${appNameVar}_db_name=${appNameVar}
                        ${appNameVar}_db_username=${appNameVar}
                        ${appNameVar}_db_password=${appNameVar}
                        ${appNameVar}_db_hostname=localhost
                            """.stripIndent())
            }

    }

    static mongodb() {
        println "  - Adding mongodb stuff..."

        write(playbook, "\n    - mongodb")
    }

    static write(File file, String str, boolean append = true) {
        if (append) {
            file?.withWriterAppend { writer -> writer.append(str) }
        } else {
            file?.withWriter { writer -> writer.append(str) }
        }
    }
}
