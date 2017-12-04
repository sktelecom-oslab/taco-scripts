#!/bin/bash
set -ex

export LC_ALL="en_US.UTF-8"
apt-get update
apt-get -y upgrade
apt install -y python python-pip git jq nmap bridge-utils ipcalc
pip install --upgrade pip
pip install -U ansible
pip install netaddr
pip install pyOpenSSL==16.2.0
apt install -y sudo ceph-common

swapoff -a
modprobe rbd
