#!/bin/sh
exec java -Dlog4j.configuration=file:/usr/lib/nameindexer/log4j.xml -Dfile.encoding=UTF8 -Djava.util.Arrays.useLegacyMergeSort=true {{ nameindexer_opts | default('-Xmx1g -Xms1g') }} -jar $0 "$@"


