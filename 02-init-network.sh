#!/bin/bash
dmesg | grep -q "BIOS Google"
case $? in
(0) echo Sorry. GCE instance needs 2 nics to deploy TACO 2.0; exit;;
esac
set -ex
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')
EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
brctl addbr br-data
brctl addif br-data $EXNIC
ip link set br-data up
ip link add veth0 type veth peer name veth1
ip link set veth0 up
ip link set veth1 up
brctl addif br-data veth1
ip addr del $EXIP/24 dev $EXNIC
ip addr add $EXIP/24 dev br-data
route add default gw $EXGW

echo $EXIP 'taco-aio' >> /etc/hosts
