#!/bin/bash
set -ex
cd ~/
git clone https://github.com/sktelecom-oslab/taco-kubespray.git
ansible-playbook -u root -b -i ~/taco-kubespray/inventory/taco-aio.cfg ~/taco-kubespray/cluster.yml
