#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

export LC_ALL="en_US.UTF-8"

EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
echo $EXIP 'taco-aio' >> /etc/hosts

OS_DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
if [ $OS_DISTRO == CentOS ]; then
    yum update
    yum install -y yum-utils python-pip python-devel
    yum -y install ceph-common git jq nmap bridge-utils net-tools
    yum -y install https://centos7.iuscommunity.org/ius-release.rpm
    yum -y install python36u python36u-devel
elif [ $OS_DISTRO == Ubuntu ]; then
    apt-get update
    apt-get -y upgrade
    apt install -y python python-pip
    apt install -y ceph-common git jq nmap bridge-utils ipcalc
fi
pip install --upgrade pip
pip install 'pbr>=1.6'
pip install 'ansible>=2.4.0'
pip install 'netaddr'
pip install 'jinja2>=2.9.6'
pip install 'pyOpenSSL==16.2.0'
pip install 'python-openstackclient==3.12.0'


swapoff -a
modprobe rbd
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
