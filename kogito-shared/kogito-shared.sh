#!/bin/bash

source ../common-functions.sh

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling kogito-shared"
  oc delete -f kogito-configs.yaml

elif [ "${action}" == "install" ]; then
  echo "*** installing kogito-share"

  sed 's@${project_name}@'$(getProjectName)'@;s@${apps_cluster_host}@'$(getClusterAppsHostname)'@' \
        ./kogito-configs.yaml > ./kogito-configs-updated.yaml
  oc create -f kogito-configs-updated.yaml
  rm kogito-configs-updated.yaml
fi