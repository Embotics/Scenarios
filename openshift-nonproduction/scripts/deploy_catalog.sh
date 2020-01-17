#!/bin/bash
#
# deploy_catalog.sh
#

# set the template locations
IMAGESTREAMDIR=~/openshift-ansible/roles/openshift_examples/files/examples/latest/image-streams
DBTEMPLATES=~/openshift-ansible/roles/openshift_examples/files/examples/latest/db-templates
QSTEMPLATES=~/openshift-ansible/roles/openshift_examples/files/examples/latest/quickstart-templates

# create the streams and templates
oc create -f $IMAGESTREAMDIR/image-streams-centos7.json -n openshift
oc create -f $DBTEMPLATES -n openshift
oc create -f $QSTEMPLATES -n openshift

echo "Done"
