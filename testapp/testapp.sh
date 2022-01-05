#!/bin/bash

action=$1

function waitForPod(){
  podNameStart=$1

  res=$(oc get pod | grep "${podNameStart}" | awk '{print $3}')
  until [ "${res}" == "Running" ]
  do
    echo waiting for "${podNameStart}"
    sleep 2
    res=$(oc get pod | grep "${podNameStart}" | awk '{print $3}')
    echo  "pod status is:"$res
  done
}

if [ ${action} == 'install' ]; then
#  podman pull quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0
  oc new-app quay.io/dmartino/kogito-travel-agency-travels-jvm:1.14.0.Final
  oc patch deployment kogito-travel-agency-travels-jvm --patch "$(cat deployment_patch_travels.json)"
  oc patch service kogito-travel-agency-travels-jvm --patch "$(cat service_patch_travels.json)"
  oc expose service/kogito-travel-agency-travels-jvm

#  podman pull quay.io/uegozi/kogito-travel-agency-visas-jvm:1.0.0
  oc new-app quay.io/dmartino/kogito-travel-agency-visas-jvm:1.14.0.Final
  oc patch deployment kogito-travel-agency-visas-jvm --patch "$(cat deployment_patch_visas.json)"
  oc patch service kogito-travel-agency-visas-jvm --patch "$(cat service_patch_visas.json)"
  oc expose service/kogito-travel-agency-visas-jvm

  # if we get a: WARNING: cannot use rsync: rsync not available in container, then the copy should still continue using tar
  if [ "$(ls -A ./protobuf)" ]; then
    waitForPod kogito-data-index
    kdi=$(oc get pods | grep kogito-data-index |  awk '{print $1}')
    oc rsync ./protobuf/ "${kdi}":/home/kogito/data/protobufs --no-perms
  fi
  if [ "$(ls -A ./svg)" ]; then
    waitForPod kogito-management-console
    kmc=$(oc get pods | grep kogito-management-console |  awk '{print $1}')
    oc rsync ./svg/ "${kmc}":/home/kogito/data/svg --no-perms
  fi

elif [ ${action} == 'uninstall' ]; then
  oc delete all --selector app=kogito-travel-agency-travels-jvm
  oc delete all --selector app=kogito-travel-agency-visas-jvm
fi

