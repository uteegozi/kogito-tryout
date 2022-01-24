#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1
type=$2

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling jobs service ${type}"
  oc delete all,configmap --selector app=kogito-jobs-service-${type}

elif [ "${action}" == "install" ]; then
  echo "*** installing jobs service ${type}"
  oc new-app quay.io/kiegroup/kogito-jobs-service-${type}:${KOGITO_VERSION}
  waitForPod kogito-jobs-service
  oc patch deployment kogito-jobs-service-${type} --patch "$(cat deployment-patch-${type}.yaml)"
  waitForPod kogito-jobs-service
  oc expose service/kogito-jobs-service-${type}
else
  echo "*** no such action: $action"
fi