#!/bin/bash
#
# setup_masteri_3.9.sh
#

# update yum and install prerequisite packages
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct

# set up docker repo
/bin/bash -c "cat > /etc/yum.repos.d/virt7-docker-common-release.repo << EOM
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
EOM"

# Install and start docker
yum -y install --enablerepo=virt7-docker-common-release ntp git expect docker
systemctl enable docker
systemctl start docker

# download and extract the source for openshift
wget https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
wget https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz
tar -zxvf openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
tar -zxvf openshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz
mv openshift-origin-client-tools-v3.9.0-191fece-linux-64bit oc-tool
export PATH=$HOME/oc-tool:$PATH


sleep 30

# Let's copy the oc, oadm and kubectl utils to /usr/local/bin/
cp -f /home/centos/openshift-nonproduction/openshift-origin-server-v3.9.0-191fece-linux-64bit/oc /usr/local/bin/
cp -f /home/centos/openshift-nonproduction/openshift-origin-server-v3.9.0-191fece-linux-64bit/kubectl /usr/local/bin/
cp -f /home/centos/openshift-nonproduction/openshift-origin-server-v3.9.0-191fece-linux-64bit/oadm /usr/local/bin/

# set openshift to startup on boot
mv /home/centos/openshift-nonproduction/templates/rc.local.39 /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# setup kubeconfig
echo "export KUBECONFIG=/openshift.local.config/master/admin.kubeconfig" >> /home/centos/.bash_profile
