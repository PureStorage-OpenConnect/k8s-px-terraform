#!/bin/bash
set -e #-u
set -o pipefail

##Help text
  howtouse() {
      echo -e "\nUsage:\n    $0\n    $0 --disable" >&2
      exit 1
  }

##Validate parameteres
  DISABLE_FLAG="false"
  if [[ "${1}" == "--disable" && "${2}" == "" ]]; then
    DISABLE_FLAG="true"
  elif [[ "${1}" != "" ]]; then
    echo -e "\n\nUnknown Command-line parameter passed."
    howtouse;
  fi

  if [[ -z ${vHOSTS} ]]; then 
    echo -e "Error: the vHOSTS environment variable not set. Please set it by assigning all host IPs separated by white space";
    echo -e "\nExample:"
    echo -e "export vHOSTS=\"192.168.10.51 192.168.10.52 192.168.10.53 192.168.10.54 192.168.10.55\"\n\n";
    exit 1;
  fi
  if [[ -z ${vSSH_USER} ]]; then
    echo -e "Error: the vSSH_USER environment variable not set. Please set with the ssh user name";
    echo -e "\nExample:"
    echo -e "export vSSH_USER=\"root\"\n\n";
    exit 1;
  fi

##Starting main process.
  if [[ "${DISABLE_FLAG}" == "true" ]]; then
    echo -e "\nTrying to disable the firewall.\n\n"
    for i in $vHOSTS; do
      echo "";
      ssh ${vSSH_USER}@${i} '
          hostname;
          sudo systemctl stop firewalld;
          sudo systemctl disable firewalld;
          sudo systemctl mask --now firewalld;
          sudo firewall-cmd --state;
          true';
      echo "";
      sleep 1
    done;
  else
    echo -e "\nShowing current firewall status, Use '--disable' parameter to disable the firewall.\n\n"
    for i in $vHOSTS; do
      echo "";
      ssh ${vSSH_USER}@${i} 'hostname; sudo firewall-cmd --state; true';
      echo "";
    done;
  fi

