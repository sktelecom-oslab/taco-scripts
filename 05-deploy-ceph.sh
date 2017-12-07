#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
CIDR=$(ipcalc -n $EXIP $EXGW | awk /'Network:'/'{print $2}')

helm install -f ~/taco-values/single/ceph.yaml ~/openstack-helm/ceph/ --namespace ceph --name ceph --set network.public=$CIDR --set network.cluster=$CIDR
