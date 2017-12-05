#!/bin/bash
set -ex
cd ~/
ansible-playbook -u root -b -i ~/taco-kubespray/inventory/taco-aio.cfg ~/taco-kubespray/monitoring.yml
