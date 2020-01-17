#!/bin/bash
#
# deploy_registry.sh

IPADDRESS=`ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}'`
IMAGESTREAMDIR=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/v3.10/image-streams
DBTEMPLATES=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/v3.10/db-templates
QSTEMPLATES=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/v3.10/quickstart-templates

# add docker options for insecure regsitry
echo "OPTIONS='--selinux-enabled --insecure-registry=172.30.0.0/16 --insecure-registry registry.embotics.com:80'" >> /etc/sysconfig/docker
systemctl restart docker
sleep 20

# create service accounts and assign policy
/home/centos/oc-tool/oc create serviceaccount registry -n default
/home/centos/oc-tool/oc adm policy add-scc-to-user privileged system:serviceaccount:default:registry

# create host mount point for stateful data for the docker registry
mkdir -p /registry
chown 1001:root /registry/
/home/centos/oc-tool/oc adm registry --service-account=registry --config=/openshift.local.config/master/admin.kubeconfig --mount-host=/registry

# expose the service and create the registry then route it
/home/centos/oc-tool/oc expose service docker-registry --hostname=`hostname` -n default
/home/centos/oc-tool/oc create -n default -f /root/openshift-nonproduction/templates/registry-console.yaml
/home/centos/oc-tool/oc create route passthrough --service registry-console --port registry-console -n default

# create the app
echo "/home/centos/oc-tool/oc new-app -n default --template=registry-console -p OPENSHIFT_OAUTH_PROVIDER_URL="https://${IPADDRESS}:8443" -p REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}') -p COCKPIT_KUBE_URL=$(oc get route registry-console -n default --template='https://{{ .spec.host }}')" 
/home/centos/oc-tool/oc new-app -n default --template=registry-console -p OPENSHIFT_OAUTH_PROVIDER_URL="https://${IPADDRESS}:8443" -p REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}') -p COCKPIT_KUBE_URL=$(oc get route registry-console -n default --template='https://{{ .spec.host }}')

# create the router
echo '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"router"}}' | oc create -f -
/home/centos/oc-tool/oc adm policy add-scc-to-user privileged system:serviceaccount:default:router
/home/centos/oc-tool/oc adm router router --replicas=1 --service-account=router

# create the actual images
cd
#git clone http://svrrepo.embotics.com/development/openshift-ansible.git
/home/centos/oc-tool/oc create -f $IMAGESTREAMDIR/image-streams-centos7.json -n openshift
/home/centos/oc-tool/oc create -f $DBTEMPLATES -n openshift
/home/centos/oc-tool/oc create -f $QSTEMPLATES -n openshift

echo "done"
