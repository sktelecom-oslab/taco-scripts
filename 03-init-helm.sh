#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

helm serve . &
sleep 3
helm repo add localhost http://localhost:8879/charts
HELM_DIR=~/apps/openstack-helm
if [ -d $HELM_DIR ]; then
  rm -rf $HELM_DIR
fi
cd ~/apps
git clone https://github.com/sktelecom-oslab/openstack-helm.git
cd ~/openstack-helm
git checkout -b 2.0.0 2.0.0
make
cd ~/
VALUES_DIR=~/taco-values
if [ -d $VALUES_DIR ]; then
  rm -rf $VALUES_DIR
fi
git clone https://github.com/sktelecom-oslab/taco-values.git
