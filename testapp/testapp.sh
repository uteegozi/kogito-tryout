#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1

if [ ${action} == 'install' ]; then

  sed 's@${project_name}@'$(getProjectName)'@;s@${apps_cluster_host}@'$(getClusterAppsHostname)'@' \
          ./kogito-app-configs.yaml > ./kogito-app-configs-updated.yaml
  oc create -f kogito-app-configs-updated.yaml
  rm kogito-app-configs-updated.yaml

  oc new-app quay.io/uegozi/kogito-travel-agency-travels-jvm:"${KOGITO_VERSION}.Final"
  oc patch deployment kogito-travel-agency-travels-jvm --patch "$(cat deployment_patch_travels.yaml)"
  oc patch service kogito-travel-agency-travels-jvm --patch "$(cat service_patch_travels.json)"
  oc expose service/kogito-travel-agency-travels-jvm

  oc new-app quay.io/uegozi/kogito-travel-agency-visas-jvm:"${KOGITO_VERSION}.Final"
  oc patch deployment kogito-travel-agency-visas-jvm --patch "$(cat deployment_patch_visas.yaml)"
  oc patch service kogito-travel-agency-visas-jvm --patch "$(cat service_patch_visas.json)"
  oc expose service/kogito-travel-agency-visas-jvm

elif [ ${action} == 'uninstall' ]; then
  oc delete all --selector app=kogito-travel-agency-travels-jvm
  oc delete all --selector app=kogito-travel-agency-visas-jvm
  oc delete configmap/kogito-app-configs
fi

