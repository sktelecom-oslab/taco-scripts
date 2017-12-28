<img src="https://github.com/sktelecom-oslab/docs/blob/master/images/taco-logo.png" width="300">

# TACO Installation Scripts

This set of scripts let anyone install TACO AIO (All-In-One) on a single machine.

* Kubernetes v1.8.1
* Helm v2.6.1
* OpenStack Ocata release
* Ceph Jewel Version 
* Weave Scope
* Prometheus 
* Grafana
* Armada

Minimum Hardware (VM) Requirements 
* Spec: 4 CPU / 16G MEMORY / 100G DISK / 1 NIC
* OS: Ubuntu 16.04.3 or CentOS 7.4 or REHL 7.4   


## TACO (SKT All Container OpenStack) 

TACO is OpenStack solution developed by SK Telecom, fully leveraging [OpenStack-Helm] project.
* 100% Community based Open Source SW with Continuous Integration / Delivery System
* Enhanced OpenStack Lifecycle Management: Self-Healing, Upgrade w/o Service Interruption, Simple and Easy Deployment, Highly Flexible Customization 
* TACO Version Info: TACO v1.x = Newton / TACO v2.x = Ocata  


## Quick Start Guide

### Download TACO Installation Scripts

    $ git clone https://github.com/sktelecom-oslab/taco-scripts.git
    $ cd taco-scripts

> You need to have 'git' installed in your server.

### Before install TACO AIO, initialize environment and install all related packages using:

    $ ./01-init-env.sh

### Deploy kubernetes cluster at your single machine:

    $ ./02-install-k8s.sh

This step contains all about deploying kubernetes using kubespray
* download kubespray and setting TACO's configurations
* deploy all-in-one kubernetes cluster
* label nodes for deploying OpenStack pods
* make some necessary clusterrolebindings

### Install [Armada] client to deploy OpenStack on Kubernetes:

    $ ./03-init-armada.sh

> Armada is a tool for managing multiple helm charts with dependencies by centralizing all configurations in a single Armada yaml and providing lifecycle hooks for all helm releases.

### Deploy OpenStack:

    $ ./04-deploy-openstack.sh

### Initialize OpenStack and Launch an instance (Virtual Machine)

    $ ./05-init-openstack.sh

First, populate environment variables with the location of the Identity service and the admin project and user credentials. This script also creates all the necessary resources to launch an instances and access it. 

* Create private network
* Create public network
* Create router
* Add security group for ssh
* Create private key
* Create virtual machine
* Add public ip to vm


----

## TACO v2.0 Release Document 

https://tde.sktelecom.com/wiki/pages/viewpage.action?pageId=146290186&
* please contact Jaesuk Ahn (jay.ahn@sk.com) to get an access to the release document.

### Acknowledgement 

This is fully inspired by OpenStack-Helm project workshop at [OpenStack Sydney Workshop].


[OpenStack-Helm]: https://github.com/openstack/openstack-helm
[OpenStack-Helm Document]: https://docs.openstack.org/openstack-helm/latest/readme.html
[OpenStack Sydney Workshop]: https://github.com/portdirect/sydney-workshop
[Armada]: http://armada-helm.readthedocs.io/en/latest/readme.html#
