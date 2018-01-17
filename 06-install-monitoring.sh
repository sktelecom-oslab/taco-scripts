#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
cd ~/
ansible-playbook -u root -b -i ~/apps/taco-kubespray/inventory/taco-aio.cfg ~/apps/taco-kubespray/monitoring.yml
