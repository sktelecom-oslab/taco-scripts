#!/bin/bash
set -ex
EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
CIDR=$(ipcalc -n $EXIP $EXGW | awk /'Network:'/'{print $2}')

helm install -f ~/taco-values/single/ingress.yaml ~/openstack-helm/ingress/ --namespace openstack --name ingress
helm install -f ~/taco-values/single/etcd.yaml ~/openstack-helm/etcd/ --namespace openstack --name etcd
helm install -f ~/taco-values/single/rabbitmq.yaml ~/openstack-helm/rabbitmq/ --namespace openstack --name rabbitmq
helm install -f ~/taco-values/single/memcached.yaml ~/openstack-helm/memcached/ --namespace openstack --name memcached

helm install -f ~/taco-values/single/ceph.yaml --namespace=openstack --name=ceph-openstack-config ~/openstack-helm/ceph/ --set network.public=$CIDR --set network.cluster=$CIDR --set deployment.storage_secrets=false  --set deployment.ceph=false  --set deployment.rbd_provisioner=false  --set deployment.client_secrets=true  --set deployment.rgw_keystone_user_and_endpoints=false --set bootstrap.enabled=false
sleep 3
helm install -f ~/taco-values/single/mariadb.yaml ~/openstack-helm/mariadb/ --namespace openstack --name mariadb
