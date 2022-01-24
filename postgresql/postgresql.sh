#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1
type=$2

selector=postgresql-13

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling postgresql"
  oc delete all,pvc --selector app="${selector}"

elif [ "${action}" == "install" ]; then
  echo "*** installing postgresql"
  oc create -f postgresql-pvc.yaml
  oc new-app registry.redhat.io/rhel8/"${selector}"
  oc patch deployment "${selector}" --patch "$(cat deployment-patch.yaml)"
  oc expose service/"${selector}"

else
  echo "*** no such action: $action"
fi