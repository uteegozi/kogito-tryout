#!/bin/bash

source installer.properties
source common-functions.sh

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
  POSTGRESQL=Y
  INFINISPAN=N
  KAFKA=Y
  KEYCLOAK=Y
  KOGITO_DATA_INDEX=Y
  KOGITO_MANAGEMENT_CONSOLE=Y
  KOGITO_TASK_CONSOLE=Y
  KOGITO_JOBS_SERVICE=Y
fi

cd testapp
    ./testapp.sh "${action}"
cd ..

componentAction "${KOGITO_DATA_INDEX}" "kogito-data-index" "$(getDb)"
componentAction "${KOGITO_MANAGEMENT_CONSOLE}" "kogito-management-console"
componentAction "${KOGITO_TASK_CONSOLE}" "kogito-task-console"
componentAction "${KOGITO_JOBS_SERVICE}" "kogito-jobs-service" "$(getDb)"

componentAction "${POSTGRESQL}" "postgresql"
componentAction "${INFINISPAN}" "infinispan"
componentAction "${KAFKA}" "kafka"
componentAction "${KEYCLOAK}" "keycloak"

componentAction "Y" "kogito-shared"






