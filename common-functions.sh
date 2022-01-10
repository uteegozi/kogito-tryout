#!/bin/bash

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