#!/bin/bash
set -ex

for NS in ceph openstack ; do
    kubectl delete --force=true --grace-period=1 --ignore-not-found=true ns $NS
    end=$(expr $(date +%s) + 20)
    while true; do
        RELEASES_CNT=$(helm list -a -q --namespace $NS | wc -l)
        [ $RELEASES_CNT -ne 0 ] && break || true
        sleep 5
        now=$(date +%s)
        [ $now -gt $end ] && echo can not find $NS releases. && break
    done
    RELEASES=$(helm list -a -q --namespace $NS)
    for RELEASE in $RELEASES ; do
        helm delete --purge --no-hooks $RELEASE
        sleep 1
    done
done

rm -rf /var/lib/openstack-helm /var/lib/neutron /var/lib/nova /var/lib/libvirt /var/lib/openvswitch /run/openvswitch* /run/libvirt*
