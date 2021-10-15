#!/bin/bash
set -e

export DOCKER_CMD="docker run --network host --rm -v {{pdf_path}}:/converted/ arachnysdocker/athenapdf athenapdf --delay=10000 --timeout=600 $@"
$DOCKER_CMD
