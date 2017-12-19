#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

ARMADA_DIR=~/apps/armada
if [ -d $ARMADA_DIR ]; then
  rm -rf $ARMADA_DIR
fi
ARMADA_MANIFEST_DIR=~/apps/armada-manifests
if [ -d $ARMADA_MANIFEST_DIR ]; then
  rm -rf $ARMADA_MANIFEST_DIR
fi
cd ~/apps
git clone http://github.com/att-comdev/armada.git && cd armada
ln -sf /usr/bin/python3 /usr/bin/python
pt-get install -y python3-pip
pip3 install .

cd ~/apps
git clone https://github.com/sktelecom-oslab/armada-manifests.git

armada apply ~/apps/armada-manifests/taco-aio-manifest.yaml 
