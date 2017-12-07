#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
cd ~/
KUBESPRAY_DIR=~/taco-kubespray
if [ -d $KUBESPRAY_DIR ]; then
  rm -rf $KUBESPRAY_DIR
fi
git clone https://github.com/sktelecom-oslab/taco-kubespray.git
ansible-playbook -u root -b -i ~/taco-kubespray/inventory/taco-aio.cfg ~/taco-kubespray/cluster.yml

kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack --overwrite
kubectl label nodes openvswitch=enabled --all --namespace=openstack --overwrite
kubectl label nodes openstack-compute-node=enabled --all --namespace=openstack --overwrite
kubectl label nodes kubernetes-control-plane=enabled --all --overwrite
kubectl label nodes ceph-mds=enabled --all --overwrite
kubectl label nodes ceph-mon=enabled --all --overwrite
kubectl label nodes ceph-osd=enabled --all --overwrite
kubectl label nodes ceph-rgw=enabled --all --overwrite

kubectl create clusterrolebinding openstack \
--clusterrole=cluster-admin \
--serviceaccount=openstack:default

kubectl create clusterrolebinding ceph \
--clusterrole=cluster-admin \
--serviceaccount=ceph:default

echo """nameserver 10.96.0.10
nameserver 8.8.8.8
nameserver 8.8.4.4
search openstack.svc.cluster.local svc.cluster.local cluster.local
options ndots:5""" > /etc/resolv.conf
