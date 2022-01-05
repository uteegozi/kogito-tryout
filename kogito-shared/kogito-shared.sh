#!/bin/bash

action=$1
what=$2

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling kogito-shared"
  if [ "${what}" == "pvc" ]; then
    oc delete -f pvc1.yaml
    oc delete -f pvc2.yaml
  elif [ "${what}" == "config" ]; then
    oc delete -f kogito-configs.yaml
  fi

elif [ "${action}" == "install" ]; then
  echo "*** installing kogito-share"
  if [ "${what}" == "pvc" ]; then
    oc create -f pvc1.yaml
    oc create -f pvc2.yaml
  elif [ "${what}" == "config" ]; then
    current_project_name=$(oc project -q)
    # get apps cluster server hostname - get current contexts api cluster name
    current_context_clustername=$(oc config current-context |  cut -d'/' -f2)
    # use the cluster name to find the cluster api url inside a possible list of clusters
    current_context_clusterurl_api=$(oc config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}' | grep "${current_context_clustername}" | awk '{print $2}')
    # only get hostname
    current_context_clusterurl_api=${current_context_clusterurl_api%:*}
    current_context_clusterurl_api=${current_context_clusterurl_api##*/}
    # replace api with apps
    current_context_clusterhost_apps="apps.${current_context_clusterurl_api#*.}"
    sed 's@${project_name}@'$current_project_name'@;s@${apps_cluster_host}@'$current_context_clusterhost_apps'@' \
          ./kogito-configs.yaml > ./kogito-configs-updated.yaml
    oc create -f kogito-configs-updated.yaml
    rm kogito-configs-updated.yaml
  fi
fi