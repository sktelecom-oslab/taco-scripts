#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
cd ~/
ansible-playbook -u root -b -i ~/taco-kubespray/inventory/taco-aio.cfg ~/taco-kubespray/monitoring.yml
