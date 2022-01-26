#!/bin/bash

source installer.properties

action=uninstall

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

componentAction "${TEST_APP}" "testapp"

dbType=""
if [ "${INFINISPAN}" == "Y" ]; then
  dbType="infinispan"
fi
componentAction "${KOGITO_DATA_INDEX}" "kogito-data-index" "${dbType}"
componentAction "${KOGITO_MANAGEMENT_CONSOLE}" "kogito-management-console"
componentAction "${KOGITO_TASK_CONSOLE}" "kogito-task-console"
componentAction "${KOGITO_JOBS_SERVICE}" "kogito-jobs-service" "${dbType}"

componentAction "${INFINISPAN}" "infinispan"
componentAction "${KAFKA}" "kafka"
componentAction "${KEYCLOAK}" "keycloak"

componentAction "Y" "kogito-shared"






