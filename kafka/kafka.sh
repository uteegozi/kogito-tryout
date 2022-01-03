#!/bin/bash

action=$1

if [ "${action}" == "uninstall" ]; then
  echo "*** uninstalling kafka"
  helm uninstall kafka
  oc delete pvc --selector app.kubernetes.io/instance=kafka

elif [ "${action}" == "install" ]; then
  echo "*** installing kafka"
  helm repo add bitnami https://charts.bitnami.com/bitnami
#  mkdir -p chart-src
#  helm pull bitnami/kafka --version "14.4.3" -d ./chart-src --untar
  helm install kafka bitnami/kafka --version "14.4.3" -f kafka-values.yaml

else
  echo "*** no such action: $action"
fi