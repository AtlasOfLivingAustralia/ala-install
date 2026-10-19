#!/bin/bash
# Spring Boot 4 jars are not executable shell scripts. Source the sibling conf
# (JAVA_HOME, JAVA_OPTS) and run java -jar from this directory.
APP_HOME="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$APP_HOME"
. "${APP_HOME}/{{ service_name }}.conf"
exec "${JAVA_HOME}/bin/java" ${JAVA_OPTS} -jar "${APP_HOME}/{{ service_name }}.jar"
