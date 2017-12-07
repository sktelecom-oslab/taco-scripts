#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')

helm install -f ~/taco-values/single/keystone.yaml ~/openstack-helm/keystone/ --namespace openstack --name keystone
helm install -f ~/taco-values/single/glance.yaml ~/openstack-helm/glance/ --namespace openstack --name glance
helm install -f ~/taco-values/single/libvirt.yaml ~/openstack-helm/libvirt/ --namespace openstack --name libvirt
helm install -f ~/taco-values/single/nova.yaml ~/openstack-helm/nova/ --namespace openstack --name nova
helm install -f ~/taco-values/single/openvswitch.yaml ~/openstack-helm/openvswitch/ --namespace openstack --name openvswitch
helm install -f ~/taco-values/single/neutron.yaml ~/openstack-helm/neutron/ --namespace openstack --name neutron --set network.interface.tunnel=$EXNIC
helm install -f ~/taco-values/single/cinder.yaml ~/openstack-helm/cinder/ --namespace openstack --name cinder
helm install -f ~/taco-values/single/horizon.yaml ~/openstack-helm/horizon/ --namespace openstack --name horizon
