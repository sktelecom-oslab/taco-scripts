#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

ARMADA_DIR=~/apps/armada
if [ -d $ARMADA_DIR ]; then
  rm -rf $ARMADA_DIR
fi

cd ~/apps
git clone http://github.com/att-comdev/armada.git && cd armada
apt-get install -y python3-pip
pip3 install --upgrade pip
pip3 install .
