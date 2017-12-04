#!/bin/bash
set -ex

export LC_ALL="en_US.UTF-8"
apt-get update
apt-get -y upgrade
apt install -y python python-pip git jq nmap bridge-utils ipcalc
apt install -y ceph-common
pip install --upgrade pip
pip install -U ansible
pip install netaddr
pip install pyOpenSSL==16.2.0
pip install python-openstackclient==3.12.0

swapoff -a
modprobe rbd
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
