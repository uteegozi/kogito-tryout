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
  INFINISPAN=Y
  KAFKA=Y
  KEYCLOAK=Y
  KOGITO_DATA_INDEX=Y
  KOGITO_MANAGEMENT_CONSOLE=Y
  KOGITO_TASK_CONSOLE=Y
  KOGITO_JOBS_SERVICE=Y
  TEST_APP=Y
fi
if [ "${KOGITO_MANAGEMENT_CONSOLE_VERSION}" == "1.8.0" ]; then
  KEYCLOAK=N
fi

if [ "${action}" == "install" ]; then
  # prepare/check prerequisites
  echo ""
fi

componentAction "Y" "kogito-shared"

componentAction "${INFINISPAN}" "infinispan"
componentAction "${KAFKA}" "kafka"
componentAction "${KEYCLOAK}" "keycloak"

dbType=""
if [ "${INFINISPAN}" == "Y" ]; then
  dbType="infinispan"
fi

componentAction "${KOGITO_DATA_INDEX}" "kogito-data-index" "${dbType}"
componentAction "${KOGITO_MANAGEMENT_CONSOLE}" "kogito-management-console"
componentAction "${KOGITO_TASK_CONSOLE}" "kogito-task-console"
componentAction "${KOGITO_JOBS_SERVICE}" "kogito-jobs-service" "${dbType}"

componentAction "${TEST_APP}" "testapp"