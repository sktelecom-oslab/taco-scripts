#!/bin/bash
export LC_ALL="en_US.UTF-8"
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://keystone-api.openstack.svc.cluster.local:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

echo "Deleting virtual machine..."
SERVERS=$(openstack server list | grep -v ID | grep -e '[a-z0-9]' | awk '{print $2}')
for server in $SERVERS
do
    openstack server delete $server --wait
done
echo "Done"

echo "Deleting secutiry group rule for ssh"
SEC_GROUP_RULES=$(openstack security group rule list | grep -E 'tcp|icmp' | awk '{print $2}')
for sec_rule in $SEC_GROUP_RULES
do
    openstack security group rule delete $sec_rule
done
echo "Done"

echo "Deleting private key"
openstack keypair delete taco-key
echo "Done"

echo "Deleting floating ip..."
FLOATING_IPS=$(openstack floating ip list | grep 192 | awk '{print $4}')
for floating_ip in $FLOATING_IPS
do
    openstack floating ip delete $floating_ip
done
echo "Done"

echo "Deleting glance image..."
IMAGES=$(openstack image list | grep -v ID | grep -e '[a-z0-9]' | grep -v 'Cirros 0.3.5 64-bit' | awk '{print $2}')
for image in $IMAGES
do
    openstack image delete $image
done
echo "Done"

echo "Deleting router..."
openstack router remove subnet admin-router private-subnet
openstack router unset admin-router
openstack router delete admin-router
echo "Done"

echo "Deleting public network..."
openstack subnet delete public-subnet
openstack network delete public-net
echo "Done"

echo "Deleting private network..."
openstack subnet delete private-subnet
openstack network delete private-net
echo "Done"

