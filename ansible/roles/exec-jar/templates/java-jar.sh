#!/bin/bash
# Spring Boot 4 jars are not executable shell scripts. Source the sibling conf
# (JAVA_HOME, JAVA_OPTS) and run java -jar from this directory.
APP_HOME="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$APP_HOME"
. "${APP_HOME}/{{ service_name }}.conf"

# JAVA_OPTS wraps settings in double quotes, preserving literal inner quotes like -Dapp.label='Bio Collect'.
# Standard unquoted expansion breaks on spaces and drops quotes, confusing Java's main class parser.
# xargs respects quoted substrings without risk of code execution (unlike eval), safely splitting arguments.
java_opts=()
if [[ -n ${JAVA_OPTS//[[:space:]]/} ]]; then
  set -o pipefail
  if ! parsed=$(printf '%s\n' "${JAVA_OPTS}" | xargs -n1 printf '%s\n'); then
    echo "Failed to parse JAVA_OPTS. A jvm_params value has an unmatched quote." >&2
    exit 1
  fi
  set +o pipefail

  # Populate the array safely from the verified variable
  mapfile -t java_opts <<< "${parsed}"
fi

if [[ {% raw %}${#java_opts[@]}{% endraw %} -eq 0 ]]; then
  echo "Failed to parse JAVA_OPTS." >&2
  exit 1
fi

exec "${JAVA_HOME}/bin/java" "${java_opts[@]}" -jar "${APP_HOME}/{{ service_name }}.jar"