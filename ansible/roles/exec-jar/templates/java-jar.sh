#!/bin/bash
# Spring Boot 4 jars are not executable shell scripts. Source the sibling conf
# (JAVA_HOME, JAVA_OPTS) and run java -jar from this directory.
APP_HOME="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$APP_HOME"
. "${APP_HOME}/{{ service_name }}.conf"

# service.conf assigns JAVA_OPTS as one double-quoted string, so quotes in a
# jvm_params entry such as -Dapp.label='Bio Collect' are stored literally.
# An unquoted ${JAVA_OPTS} expansion splits on the space and does not treat
# those quotes as argument delimiters. Java then takes Collect' as the main
# class and never applies -jar. xargs honours the quotes without executing
# the string.
java_opts=()
if [[ -n ${JAVA_OPTS//[[:space:]]/} ]]; then
  set -o pipefail
  if ! mapfile -t java_opts < <(printf '%s\n' "${JAVA_OPTS}" | xargs -n1 printf '%s\n'); then
    echo "Failed to parse JAVA_OPTS. A jvm_params value has an unmatched quote." >&2
    exit 1
  fi
  set +o pipefail
fi

if [[ ${#java_opts[@]} -eq 0 ]]; then
  echo "Failed to parse JAVA_OPTS." >&2
  exit 1
fi

exec "${JAVA_HOME}/bin/java" "${java_opts[@]}" -jar "${APP_HOME}/{{ service_name }}.jar"