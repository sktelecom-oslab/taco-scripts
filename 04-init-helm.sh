#!/bin/bash
set -ex

helm serve . &
sleep 3
helm repo add localhost http://localhost:8879/charts
cd ~/
git clone https://github.com/openstack/openstack-helm.git
cd openstack-helm
make
cd ~/
git clone https://github.com/sktelecom-oslab/taco-values.git
