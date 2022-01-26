#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling task console"
  oc delete all,configmap --selector app=kogito-task-console

elif [ "${action}" == "install" ]; then
  echo "*** installing task console"
  oc new-app quay.io/kiegroup/kogito-task-console:${KOGITO_MANAGEMENT_CONSOLE_VERSION}
  waitForPod kogito-task-console
  patchVersion=""
  if [ "${KOGITO_MANAGEMENT_CONSOLE_VERSION}" == "1.8.0" ]; then
    patchVersion="-1.8.0"
  fi
  oc patch deployment kogito-task-console --patch "$(cat deployment-patch${patchVersion}.yaml)"
  waitForPod kogito-task-console
  oc expose service/kogito-task-console
else
  echo "*** no such action: $action"
fi