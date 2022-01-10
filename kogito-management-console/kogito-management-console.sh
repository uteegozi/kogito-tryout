#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling management console"
  oc delete all --selector app=kogito-management-console

elif [ "${action}" == "install" ]; then
  echo "*** installing management console"
  oc new-app quay.io/kiegroup/kogito-management-console:"${KOGITO_MANAGEMENT_CONSOLE_VERSION}"
  waitForPod kogito-management-console
  patchVersion=""
  if [ "${KOGITO_MANAGEMENT_CONSOLE_VERSION}" == "1.8.0" ]; then
    patchVersion="1.8.0"
  fi
  oc patch deployment kogito-management-console --patch "$(cat deployment-patch-${patchVersion}.yaml)"
  waitForPod kogito-management-console
  oc expose service/kogito-management-console

else
  echo "*** no such action: $action"
fi