#!/bin/bash

action=$1
type=$2

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling data-index ${type}"
  oc delete all --selector app=kogito-data-index-"${type}"

elif [ "${action}" == "install" ]; then
  echo "*** installing data-index ${type}"
  oc new-app quay.io/kiegroup/kogito-data-index-"${type}":1.8.0
  oc patch deployment kogito-data-index-"${type}" --patch "$(cat deployment-patch-"${type}".yaml)"
  oc expose service/kogito-data-index-"${type}"

else
  echo "*** no such action: $action"
fi