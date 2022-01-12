#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1
type=$2

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling data-index ${type}"
  oc delete all,configmap --selector app=kogito-data-index-"${type}"

elif [ "${action}" == "install" ]; then
  echo "*** installing data-index ${type}"
  # cannot add a label directly to a config map create command => workaround:
  # create a configmap yaml locally -> update label on that locally => pipe into server "create cm from yaml" command
  oc create configmap data-index-config --from-file=../testapp/protobuf -o yaml --dry-run=client | \
    oc label -f- --dry-run=client -o yaml --local=true app=kogito-data-index-"${type}" | \
    oc apply -f-
#  oc new-app quay.io/kiegroup/kogito-data-index-"${type}":1.14.0 -o yaml --dry-run=true | \
#  oc patch -f- --dry-run=client --local=true --patch-file deployment-patch-"${type}".yaml | \
#  oc apply -f-
  oc new-app quay.io/kiegroup/kogito-data-index-"${type}":"${KOGITO_VERSION}"
  waitForPod kogito-data-index
  oc patch deployment kogito-data-index-"${type}" --patch "$(cat deployment-patch-"${type}".yaml)"
  waitForPod kogito-data-index
  oc expose service/kogito-data-index-"${type}"

else
  echo "*** no such action: $action"
fi