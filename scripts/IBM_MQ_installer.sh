#!/usr/bin/env bash
set -x

###################################
## https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.ins.doc/q130560_.htm
###################################


###################################
## The DRBD and Pacemaker packages are signed with the LINBIT GPG key. 
## Use the following command to import the public LINBIT GPG key:
###################################
rpm --import https://packages.linbit.com/package-signing-pubkey.asc


###################################
## Get the installation binary and extract
###################################

## 7.7
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/Ms5ayciUxAIpCtTnqQcnYk3Rmkkr8to1gEJG0wwf8PQ/n/partners/b/bucket-20200513-1843/o/mqadv_dev915_linux_x86-64.tar.gz 
tar -xvzf mqadv_dev915_linux_x86-64.tar.gz


###################################
## Accept the software license 
###################################
cd MQServer
./mqlicense.sh -accept


###################################
## Install IBM MQ, RDQM, Pacemaker, and DRBD
###################################
Advanced/RDQM/installRDQMsupport


###################################
## Install IBM MQ, RDQM, Pacemaker, and DRBD
###################################
/opt/mqm/samp/rdqm/firewalld/configure.sh


###################################
## Group assignments for the mqm and root user.
###################################
echo Ibmmq123! | sudo passwd mqm --stdin
usermod -a -G wheel mqm
usermod -a -G haclient mqm
usermod -a -G haclient root
usermod -a -G mqm root


###################################
## Verify local server installation
###################################
. /opt/mqm/bin/setmqenv -s
if dspmqver ; then 
  echo "Check...................1/1" 
else 
  echo "ERROR! Installation Failed."  
  exit
fi
