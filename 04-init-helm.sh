#!/bin/bash
set -ex

helm serve . &
sleep 3
helm repo add localhost http://localhost:8879/charts
cd ~/
HELM_DIR=~/openstack-helm
if [ -d $HELM_DIR ]; then
  rm -rf $HELM_DIR
fi
git clone https://github.com/openstack/openstack-helm.git
cd ~/openstack-helm
git checkout cae76dc9ab94f48259a8514075efb76f088a2722
make
cd ~/
VALUES_DIR=~/taco-values
if [ -d $VALUES_DIR ]; then
  rm -rf $VALUES_DIR
fi
git clone https://github.com/sktelecom-oslab/taco-values.git
