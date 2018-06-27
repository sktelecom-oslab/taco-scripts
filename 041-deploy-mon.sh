#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
armada apply ~/apps/armada-manifests/taco-mon-manifest.yaml 
