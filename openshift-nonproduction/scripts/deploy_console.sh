#!/bin/bash
#
# deploy_console.sh

IPADDRESS=`ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}'`

# kubeconfig
mkdir -p ~/.kube
cp -f /openshift.local.config/master/admin.kubeconfig ~/.kube/config

# required for the web console
cp -f /home/centos/openshift-nonproduction/templates/console-config.yaml ./
cp -f /home/centos/openshift-nonproduction/templates/console-template.yaml ./
sed -i -e 's/127.0.0.1/'$IPADDRESS'/g' console-config.yaml

# create the console
/home/centos/oc-tool/oc create namespace openshift-web-console
/home/centos/oc-tool/oc process -f console-template.yaml -p "API_SERVER_CONFIG=$(cat console-config.yaml)" | /home/centos/oc-tool/oc apply -n openshift-web-console -f -

echo "Done"
