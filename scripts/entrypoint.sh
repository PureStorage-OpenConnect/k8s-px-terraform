#!/usr/bin/env bash
set -e -u -x
set -o pipefail

#exec terraform "$@"

#check if the current user is root
if [ "$(id -u)" = "0" ]; then 
    echo "Running as root"
fi
