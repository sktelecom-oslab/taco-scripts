#!/bin/bash
set -ex
apt-get update
apt-get -y upgrade
apt install -y python python-pip git jq nmap bridge-utils
pip install --upgrade pip
pip install -U ansible
pip install netaddr
pip install pyOpenSSL==16.2.0

swapoff -a

export LC_ALL="en_US.UTF-8"
