#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
CIDR=$(ipcalc -n $EXIP $EXGW | awk /'Network:'/'{print $2}')

helm install -f ~/taco-values/single/ingress.yaml ~/openstack-helm/ingress/ --namespace openstack --name ingress
helm install -f ~/taco-values/single/etcd.yaml ~/openstack-helm/etcd/ --namespace openstack --name etcd
helm install -f ~/taco-values/single/rabbitmq.yaml ~/openstack-helm/rabbitmq/ --namespace openstack --name rabbitmq
helm install -f ~/taco-values/single/memcached.yaml ~/openstack-helm/memcached/ --namespace openstack --name memcached

helm install -f ~/taco-values/single/ceph_config.yaml --namespace=openstack --name=ceph-openstack-config ~/openstack-helm/ceph/ --set network.public=$CIDR --set network.cluster=$CIDR
sleep 3
helm install -f ~/taco-values/single/mariadb.yaml ~/openstack-helm/mariadb/ --namespace openstack --name mariadb
