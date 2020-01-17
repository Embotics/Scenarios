#!/bin/bash
#
# deploy_catalog.sh
#

# set the template locations
IMAGESTREAMDIR=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/latest/image-streams
DBTEMPLATES=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/latest/db-templates
QSTEMPLATES=/home/centos/openshift-nonproduction/openshift-ansible/roles/openshift_examples/files/examples/latest/quickstart-templates

# create the streams and templates
/home/centos/oc-tool/oc create -f $IMAGESTREAMDIR/image-streams-centos7.json -n openshift
/home/centos/oc-tool/oc create -f $DBTEMPLATES -n openshift
/home/centos/oc-tool/oc create -f $QSTEMPLATES -n openshift

echo "Done"
