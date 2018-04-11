#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1

export LC_ALL="en_US.UTF-8"
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://keystone-api.openstack.svc.cluster.local:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

echo """nameserver 10.96.0.10
nameserver 8.8.8.8
nameserver 8.8.4.4
search openstack.svc.cluster.local svc.cluster.local cluster.local
options ndots:5""" > /etc/resolv.conf

echo "Create private network..."
PRIVATE_NAME_TEMP=$(openstack network list | grep private-net | awk '{print $4}')
if [ "x${PRIVATE_NAME_TEMP}" != "xprivate-net" ]; then
    openstack network create --internal --share --project admin --provider-network-type vxlan private-net
    openstack subnet create --ip-version 4 --network private-net --subnet-range 172.30.1.0/24 --dns-nameserver 8.8.8.8 private-subnet
fi
echo "Done"

echo "Create public network..."
PUBLIC_NAME_TEMP=$(openstack network list | grep public-net | awk '{print $4}')
if [ "x${PUBLIC_NAME_TEMP}" != "xpublic-net" ]; then
    openstack network create --external --share --provider-network-type flat --provider-physical-network external public-net
    openstack subnet create --network public-net --subnet-range 10.123.123.0/24 --no-dhcp --gateway 10.123.123.1 \
        --ip-version 4 public-subnet
fi
ip addr add 10.123.123.1/24 dev br-ex
ip link set br-ex up
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')
iptables -t nat -A POSTROUTING -o $EXNIC -j MASQUERADE
echo "Done"

echo "Create router..."
ADMIN_ROUTER_TEMP=$(openstack router list | grep admin-router | awk '{print $4}')
if [ "x${ADMIN_ROUTER_TEMP}" != "xadmin-router" ]; then
    openstack router create admin-router
    openstack router add subnet admin-router private-subnet
    openstack router set --external-gateway public-net admin-router
    openstack router show admin-router
fi
echo "Done"

echo "Add security group for ssh"
SEC_GROUPS=$(openstack security group list --project admin | grep default | awk '{print $2}')
for sec_var in $SEC_GROUPS
do
    SEC_RULE=$(openstack security group rule list $SEC_GROUPS | grep 1:65535 | awk '{print $8}')
    if [ "x${SEC_RULE}" != "x1:65535" ]; then
        openstack security group rule create --proto tcp --remote-ip 0.0.0.0/0 --dst-port 1:65535 --ingress  $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 --egress $sec_var
    fi
done
echo "Done"

echo "Create private key"
    openstack keypair create --public-key ~/.ssh/id_rsa.pub taco-key
echo "Done"

IMAGE=$(openstack image show 'Cirros 0.3.5 64-bit' | grep id | awk '{print $4}')
FLAVOR=$(openstack flavor list | grep m1.tiny | awk '{print $2}')
NETWORK=$(openstack network list | grep private-net | awk '{print $2}')

echo "Create virtual machine..."
openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test --wait
echo "Done"

echo "Add public ip to vm..."
openstack floating ip create public-net
FLOATING_IP=$(openstack floating ip list | grep 10 | awk '{print $4}')
SERVER=$(openstack server list | grep test | awk '{print $2}')

sleep 10

openstack server add floating ip $SERVER $FLOATING_IP
openstack server list
echo "Done"
