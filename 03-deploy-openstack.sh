#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
CIDR=$(ipcalc -n $EXIP $EXGW | awk /'Network:'/'{print $2}')
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')

ARMADA_DIR=~/apps/armada
if [ -d $ARMADA_DIR ]; then
  rm -rf $ARMADA_DIR
fi
ARMADA_MANIFEST_DIR=~/apps/armada-manifests
if [ -d $ARMADA_MANIFEST_DIR ]; then
  rm -rf $ARMADA_MANIFEST_DIR
fi
cd ~/apps
git clone http://github.com/att-comdev/armada.git && cd armada
ln -sf /usr/bin/python3 /usr/bin/python
apt-get install -y python3-pip
pip3 install --upgrade pip
pip3 install .

cd ~/apps
git clone https://github.com/sktelecom-oslab/armada-manifests.git

armada apply ~/apps/armada-manifests/taco-aio-manifest.yaml \
	--set chart:ceph:values:network:public=$CIDR \
	--set chart:ceph:values:network:cluster=$CIDR \
	--set chart:ceph-openstack-config:values:network:public=$CIDR \
	--set chart:ceph-openstack-config:values:network:cluster=$CIDR \
	--set chart:neutron:values:network:interface:tunnel=$EXNIC
