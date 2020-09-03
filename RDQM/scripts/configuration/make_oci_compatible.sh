#!/bin/bash

## Exit if any errors encountered
set -e

##############################################################
## Before this script is run on a vanilla rhel image 
## the following steps must be manually performed.
##
## 1. Disable root password:
##        
##   $> ssh opc@<ip_address> 
##        <enter_root_password>
##   $> sudo -i 
##        <enter_root_password>
##   $> passwd -d root
##
## 2. Setup passwordless ssh logins:
##
##   /etc/ssh/sshd_config
##   "PasswordAuthentication no"
## 
## 3. You MUST register with your own RedHat credentials (free).
##  
##   $> subscription-manager remove --all
##   $> subscription-manager unregister
##   $> subscription-manager clean
##   $> subscription-manager register --username <username> --password <password> --auto-attach
##
## 4. If you get any "403 Error" you may need to issue the following command:
##
##   $> subscription-manager repos --disable=rhel-7-server-rt-beta-rpms
## 
##############################################################


## The bare minimum to get rhel to work in oci.
yum -y install cloud-init bind-utils wget rsync


## The following are optional. They are not needed for a minimum
## working version of RHEL in OCI, but I find having them installed to be useful.
yum -y -q install  OpenIPMI-modalias.x86_64 OpenIPMI-libs.x86_64 \
                    libyaml.x86_64 PyYAML.x86_64 libesmtp.x86_64 \
                    net-snmp-libs.x86_64 net-snmp-agent-libs.x86_64 \
                    openhpi-libs.x86_64 libtool-ltdl.x86_64 perl-TimeDate.x86_64


## Install Oracle Cloud agent. Will get reprimanded if not installed (eventaully).
curl -O https://objectstorage.us-phoenix-1.oraclecloud.com/p/qnGdEeuts2qRSn4EwOfEb9cys9fYRmyGn6EDsmsg_2I/n/imagegen/b/agents/o/oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm -v
yum install -y oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm
rm -f oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm


## Network Manager must be disabled for unknown reasons.
## It will probably be re-enabled in Oracle Linux 8 (so here as well).
systemctl disable NetworkManager


## We need the 'jq' package for some exit-hook dhcp scripts.
curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm
yum install -y jq
epel_release=`rpm -qa | grep epel-release`
yum remove -y ${epel_release}
rm -f epel-release-latest-7.noarch.rpm

## Get the 7.x version number to determine which packages to download later.
if cat /etc/redhat-release | grep "7.8"; then
  minor_version="8"
elif cat /etc/redhat-release | grep "7.7"; then
  minor_version="7"
else
  cat /etc/redhat-release
  echo "Must be Red Hat release version 7.7 or 7.8"
  exit 1
fi

## Download and install additional cloud-init scripts taken from
## the equivalent version on Oracle Linux platforms.
cd /etc/cloud/cloud.cfg.d
wget https://github.com/oracle-quickstart/oci-ibm-mq/raw/master/scripts/configuration/cloud.cfg.d_7.${minor_version}.tar.gz 
tar -xzvf cloud.cfg.d_7.${minor_version}.tar.gz 
rm -f cloud.cfg.d_7.${minor_version}.tar.gz 

## Download and install additional dhcp scripts taken from
## the equivalent version on Oracle Linux platforms.
cd /etc/dhcp/
wget https://github.com/oracle-quickstart/oci-ibm-mq/raw/master/scripts/configuration/dhcp_7.${minor_version}.tar.gz
tar -xzvf dhcp_7.${minor_version}.tar.gz
rm -f dhcp_7.${minor_version}.tar.gz
chmod 755 dhclient-exit-hooks
chmod 755 exit-hooks.d/dhclient-exit-hook-set-hostname.sh 

## Get the oci-hostname.conf from Oracle Linux. Not really needed
## as default behavior is the same. But might be required in the future.
cd /etc/
wget https://raw.githubusercontent.com/oracle-quickstart/oci-ibm-mq/master/scripts/configuration/oci-hostname.conf


## Remove any baked in subscription information.
## Download the oci cleanup script to clear the system of all history, ssh keys, etc.
cd /tmp
wget https://raw.githubusercontent.com/oracle/oci-utils/master/libexec/oci-image-cleanup
chmod 700 oci-image-cleanup
subscription-manager remove --all
subscription-manager unregister 
subscription-manager clean
./oci-image-cleanup -f

##################################################
## IMPORTANT:
##
## After the oci-image-cleanup script run, you want
## to burn the new custom images. You should not 
## issue ANY commands after the oci-image-cleanup
## script finishes running.
##################################################
