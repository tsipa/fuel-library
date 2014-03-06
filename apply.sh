#!/bin/sh
rm -rf "fuel_library"
#git clone https://github.com/tsipa/fuel-library/
git clone https://github.com/tsipa/fuel-library/
cd fuel-library
git checkout mongo41
#git fetch https://review.openstack.org/stackforge/fuel-library refs/changes/01/71901/5 && git checkout FETCH_HEAD
mkdir /etc/puppet/modules/
mkdir /etc/puppet/manifests/
cp -a deployment/puppet/* /etc/puppet/modules/
cd ..

local_modules="/etc/puppet/modules"
local_manifests="/etc/puppet/manifests"
main_manifest="/etc/puppet/manifests/site.pp"

#puppet apply --verbose --debug --trace "${main_manifest}"

