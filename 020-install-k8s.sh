#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
export PATH=$PATH:/usr/local/bin
cd ~/
mkdir -p ~/apps
TACO_KUBESPRAY_DIR=~/apps/taco-kubespray
if [ -d $TACO_KUBESPRAY_DIR ]; then
  rm -rf $TACO_KUBESPRAY_DIR
fi
UPSTREAM_KUBESPRAY_DIR=~/apps/upstream-kubespray
if [ -d $UPSTREAM_KUBESPRAY_DIR ]; then
  rm -rf $UPSTREAM_KUBESPRAY_DIR
fi
KUBESPRAY_DIR=~/apps/kubespray
if [ -d $KUBESPRAY_DIR ]; then
  rm -rf $KUBESPRAY_DIR
fi
CACHE_FILE=/tmp/taco-aio
if [ -f $CACHE_FILE ]; then
  rm -f $CACHE_FILE
fi
cd ~/apps
git clone https://github.com/kubernetes-incubator/kubespray.git upstream-kubespray && cd upstream-kubespray
git checkout -b v2.4.0 tags/v2.4.0
pip install -r requirements.txt

cd ~/apps
git clone https://github.com/sktelecom-oslab/taco-kubespray.git && cd taco-kubespray
git checkout -b v2.4.0 tags/v2.4.0

cd ~/apps
cp -R upstream-kubespray kubespray && cp -R taco-kubespray/* kubespray/. && cd kubespray
echo """taco-aio ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases 
[kube-master]
taco-aio
[etcd]
taco-aio
[kube-node]
taco-aio
[k8s-cluster:children]
kube-node
kube-master""" > inventory/taco-aio.cfg

ansible-playbook -u root -b -i ~/apps/kubespray/inventory/taco-aio.cfg ~/apps/kubespray/cluster.yml

ansible-playbook -u root -b -i ~/apps/kubespray/inventory/taco-aio.cfg ~/apps/kubespray/weavescope.yml

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | cat > /tmp/helm_script.sh \
&& chmod 755 /tmp/helm_script.sh && /tmp/helm_script.sh --version v2.8.2

helm init --upgrade

kubectl label nodes openstack-control-plane=enabled --all --namespace=openstack --overwrite
kubectl label nodes openvswitch=enabled --all --namespace=openstack --overwrite
kubectl label nodes openstack-compute-node=enabled --all --namespace=openstack --overwrite
kubectl label nodes kubernetes-control-plane=enabled --all --overwrite
kubectl label nodes ceph-mds=enabled --all --overwrite
kubectl label nodes ceph-mon=enabled --all --overwrite
kubectl label nodes ceph-osd=enabled --all --overwrite
kubectl label nodes ceph-rgw=enabled --all --overwrite
kubectl label nodes ceph-mgr=enabled --all --overwrite

kubectl create clusterrolebinding openstack \
--clusterrole=cluster-admin \
--serviceaccount=openstack:default

kubectl create clusterrolebinding ceph \
--clusterrole=cluster-admin \
--serviceaccount=ceph:default

echo """nameserver 10.96.0.10
nameserver 8.8.8.8
nameserver 8.8.4.4
search openstack.svc.cluster.local svc.cluster.local cluster.local
options ndots:5""" > /etc/resolv.conf

set -e

# From Kolla-Kubernetes, orginal authors Kevin Fox & Serguei Bezverkhi
# Default wait timeout is 600 seconds
end=$(expr $(date +%s) + 600)
while true; do
    kubectl get pods --namespace=kube-system -o json | jq -r \
        '.items[].status.phase' | grep Pending > /dev/null && \
        PENDING=True || PENDING=False
    query='.items[]|select(.status.phase=="Running")'
    query="$query|.status.containerStatuses[].ready"
    kubectl get pods --namespace=kube-system -o json | jq -r "$query" | \
        grep false > /dev/null && READY="False" || READY="True"
    kubectl get jobs -o json --namespace=kube-system | jq -r \
        '.items[] | .spec.completions == .status.succeeded' | \
        grep false > /dev/null && JOBR="False" || JOBR="True"
    [ $PENDING == "False" -a $READY == "True" -a $JOBR == "True" ] && \
        break || true
    sleep 5
    now=$(date +%s)
    [ $now -gt $end ] && echo containers failed to start. && \
        kubectl get pods --namespace kube-system -o wide && exit -1
done
