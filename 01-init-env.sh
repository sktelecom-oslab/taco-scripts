#!/bin/bash
set -ex

export LC_ALL="en_US.UTF-8"

apt-get update
apt-get -y upgrade

apt install -y python python-pip
pip install --upgrade pip
pip install pbr>=1.6
pip install ansible>=2.4.0
pip install netaddr
pip install jinja2>=2.9.6
pip install pyOpenSSL==16.2.0
pip install python-openstackclient==3.12.0

apt install -y ceph-common git jq nmap bridge-utils ipcalc

swapoff -a
modprobe rbd
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
