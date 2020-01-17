#!/bin/bash
#
# deploy_console.sh

IPADDRESS=`ifconfig ens32 | grep inet | grep -v inet6 | awk '{print $2}'`

# kubeconfig
mkdir -p ~/.kube
cp -f /openshift.local.config/master/admin.kubeconfig ~/.kube/config

# required for the web console
cp -f templates/console-config.yaml ./
cp -f templates/console-template.yaml ./
sed -i -e 's/127.0.0.1/'$IPADDRESS'/g' console-config.yaml

# create the console
oc create namespace openshift-web-console
oc process -f console-template.yaml -p "API_SERVER_CONFIG=$(cat console-config.yaml)" | oc apply -n openshift-web-console -f -

echo "Done"
