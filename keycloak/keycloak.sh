#!/bin/bash

source ../installer.properties
source ../common-functions.sh

action=$1

# NOTE: if need to update kogito_realm.json, replace kogito-realm-orig.json here
function updateClientRedirectUrls(){
  mngConsole=\"http://kogito-management-console-$(getProjectName).$(getClusterAppsHostname)\"
  taskConsole=\"http://kogito-task-console-$(getProjectName).$(getClusterAppsHostname)\"
  additionalRedirectUris=["${mngConsole}","${taskConsole}"]
  (jq '(.clients[] | select(.clientId=="kogito-console-quarkus") | .redirectUris) |= . + '${additionalRedirectUris} kogito-realm-orig.json) > kogito-realm.json
}
updateClientRedirectUrls

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling keycloak"
  oc delete all,configmap --selector app=keycloak

elif [ "${action}" == "install" ]; then
  echo "*** installing keycloak"
  oc create configmap keycloak-config --from-file=./kogito-realm.json -o yaml --dry-run=client | \
    oc label -f- --dry-run=client -o yaml --local=true app=keycloak | \
    oc apply -f-
  oc new-app jboss/keycloak:15.0.2
  waitForPod keycloak
  oc patch deployment keycloak --patch "$(cat deployment-patch.yaml)"
  waitForPod keycloak
  oc expose service/keycloak

else
  echo "*** no such action: $action"
fi