#!/bin/bash

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling infinispan"
  helm uninstall infinispan
  oc delete pvc,secret --selector clusterName=infinispan

elif [ "${action}" == "install" ]; then
  echo "*** installing infinispan"
  helm repo add openshift-helm-charts https://charts.openshift.io/
#  mkdir -p chart-src
#  helm pull openshift-helm-charts/infinispan-infinispan --version "0.2.0"  -d ./chart-src --untar
  helm install infinispan openshift-helm-charts/infinispan-infinispan --version "0.2.0" -f infinispan-values.yaml

else
  echo "*** no such action: $action"
fi