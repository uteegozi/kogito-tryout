#!/bin/bash

# install firstly any Kogito unrelated infrastructure like infinispan, kafka, etc.
# install secondly any Kogito services like data-index, management console, etc.
# install thirdly the application to try out

source installer.properties
source common-functions.sh

action=install

function componentAction(){
  doComponent=$1
  component=$2
  extraVar=$3

  if [ "${doComponent}" == "Y" ]; then
    cd "${component}"
    ./"${component}".sh "${action}" "${extraVar}"
    cd ..
  fi
}

if [ "${INSTALL_ALL}" == "Y" ]; then
  INFINISPAN=N
  KAFKA=Y
  KEYCLOAK=Y
  KOGITO_DATA_INDEX=Y
  KOGITO_MANAGEMENT_CONSOLE=Y
fi
if [ "${KOGITO_MANAGEMENT_CONSOLE_VERSION}" == "1.8.0" ]; then
  KEYCLOAK=N
fi

if [ "${action}" == "install" ]; then
  # prepare/check prerequisites
  echo ""
fi

componentAction "Y" "kogito-shared" "config"
componentAction "Y" "kogito-shared" "pvc"

componentAction "${INFINISPAN}" "infinispan"
componentAction "${KAFKA}" "kafka"
componentAction "${KEYCLOAK}" "keycloak"

dbType=""
if [ "${INFINISPAN}" == "Y" ]; then
  dbType="infinispan"
fi
componentAction "${KOGITO_DATA_INDEX}" "kogito-data-index" "${dbType}"
componentAction "${KOGITO_MANAGEMENT_CONSOLE}" "kogito-management-console"

cd testapp
    ./testapp.sh "${action}"
cd ..


#to check
# PVC stuck in terminating
#oc patch pvc data-kafka-zookeeper-0 -p '{"metadata":{"finalizers": []}}' --type=merge
# pod stuck in terminating
#oc delete --grace-period=0 --force pod <POD>
# test app resources are copied to both path - also need to copy them after pods are created and then restart them???
