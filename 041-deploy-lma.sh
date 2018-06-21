#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex
# compare kernel version using float and string; return 0 when greather or equal
isge () {
  lestr=$(echo $(printf "$1\n$2" | sort -V) | awk '{print $1}')
  if [[ $1 == $2 ]]; then
    return 0
  elif [[ $1 == $lestr ]]; then
    return 1
  else
    return 0
  fi
}

EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
EXGW=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $3}')
EXNIC=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $5}')
FSID=$(uuidgen)

KVER=$(uname -r | egrep '^[0-9]*\.[0-9]*' -o | head -n 1)
if isge $KVER 4.5; then
  CRUSH_TUNABLES=jewel
elif isge $KVER 4.1; then
  CRUSH_TUNABLES=hammer
elif isge $KVER 3.15; then
  CRUSH_TUNABLES=firefly
elif isge $KVER 3.9; then
  CRUSH_TUNABLES=bobtail
elif isge $KVER 3.6; then
  CRUSH_TUNABLES=argonaut
else
  CRUSH_TUNABLES=default
fi

OS_DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
if [ $OS_DISTRO == Red ]; then
    MASK=$(ifconfig $EXNIC | awk '/netmask /{ print $4;}')
    CIDR=$(ipcalc -n $EXIP $MASK | cut -d'=' -f2)/$(ipcalc -p $EXIP $MASK | cut -d'=' -f2)
elif [ $OS_DISTRO == CentOS ]; then
    MASK=$(ifconfig $EXNIC | awk '/netmask /{ print $4;}')
    CIDR=$(ipcalc -n $EXIP $MASK | cut -d'=' -f2)/$(ipcalc -p $EXIP $MASK | cut -d'=' -f2)
elif [ $OS_DISTRO == Ubuntu ]; then
    CIDR=$(ipcalc -n $EXIP $EXGW | awk /'Network:'/'{print $2}')
fi
ARMADA_MANIFEST_DIR=~/apps/armada-manifests
if [ -d $ARMADA_MANIFEST_DIR ]; then
  rm -rf $ARMADA_MANIFEST_DIR
fi

cd ~/apps
git clone https://github.com/sktelecom-oslab/armada-manifests.git
git checkout -b lma origin/lma

armada apply ~/apps/armada-manifests/taco-lma-manifest.yaml 
