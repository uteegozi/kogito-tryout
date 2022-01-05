#!/bin/bash

source ../installer.properties

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling management console"
  oc delete all --selector app=kogito-management-console

elif [ "${action}" == "install" ]; then
  echo "*** installing management console"
  oc new-app quay.io/kiegroup/kogito-management-console:"${KOGITO_VERSION}"
  oc patch deployment kogito-management-console --patch "$(cat deployment-patch.yaml)"
  oc expose service/kogito-management-console

else
  echo "*** no such action: $action"
fi