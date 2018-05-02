#!/bin/bash
set -ex

for NS in ceph openstack ; do
    kubectl delete --force=true --grace-period=1 --ignore-not-found=true ns $NS
    end=$(expr $(date +%s) + 10)
    while true; do
        RELEASES_CNT=$(helm list -a -q --namespace $NS | wc -l)
        [ $RELEASES_CNT -ne 0 ] && break || true
        sleep 2
        now=$(date +%s)
        [ $now -gt $end ] && echo can not find $NS releases. && break
    done
    RELEASES=$(helm list -a -q --namespace $NS)
    for RELEASE in $RELEASES ; do
        helm delete --purge --no-hooks $RELEASE
        sleep 1
    done
done
kubectl delete pv --all

OS_DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
if [ $OS_DISTRO == Red ]; then
    pip3.6 uninstall -y armada || true
elif [ $OS_DISTRO == CentOS ]; then
    pip3.6 uninstall -y armada || true
elif [ $OS_DISTRO == Ubuntu ]; then
    pip3 uninstall -y armada || true
else
    echo "This Linux Distribution is NOT supported"
fi

sed -i 7,18d ~/apps/kubespray/reset.yml
ansible-playbook -u root -b -i ~/apps/kubespray/inventory/taco-aio.cfg ~/apps/kubespray/reset.yml

docker rm -f $(docker ps -a -q) || true
docker rmi -f $(docker images -a -q) || true
docker system prune -a -f || true

ip addr delete 10.123.123.1/24 dev br-ex || true
ip link set br-ex down || true
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')
iptables -t nat -D POSTROUTING -o $EXNIC -j MASQUERADE || true

sed -i '/taco/d' /etc/hosts

rm -rf /var/lib/openstack-helm /var/lib/neutron /var/lib/nova /var/lib/libvirt /var/lib/openvswitch /run/openvswitch* /run/libvirt*
