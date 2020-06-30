#!/usr/bin/env bash
set -x

###################################
## https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.ins.doc/q130560_.htm
###################################

###################################
## There are some changes to the Linux kernel configuration.
##
## https://github.com/ibm-messaging/mq-rdqm/blob/master/cloud/azure/Image.md
###################################

## These changes were not implemented. The modification to 
## the /etc/sysctl.conf causes issues with the iscsi calls
## for attaching block volumens.

# cp /etc/sysctl.conf /etc/sysctl.conf.bkp
# echo 'kernel.sem = 32 4096 32 128' >> /etc/sysctl.conf
# echo 'kernel.threads-max = 32768' >> /etc/sysctl.conf
# echo 'fs.file-max = 524288' >> /etc/sysctl.conf
# echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
# sysctl -p
# cp /etc/security/limits.conf /etc/security/limits.conf.bkp
# echo '* - nofile 10240' >> /etc/security/limits.conf
# echo 'root - nofile 10240' >> /etc/security/limits.conf


###################################
## The DRBD and Pacemaker packages are signed with the LINBIT GPG key. 
## Use the following command to import the public LINBIT GPG key:
###################################
rpm --import https://packages.linbit.com/package-signing-pubkey.asc


###################################
## Get the installation binary and extract
###################################
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/MHNlnxzh2geqvDGIppXsM3qjbxJ_R-7F8VxCaPq-v5g/n/partners/b/bucket-20200513-1843/o/mqadv_dev915_linux_x86-64.tar.gz
tar -xvzf mqadv_dev915_linux_x86-64.tar.gz


###################################
## Accept the software license 
###################################
cd MQServer
./mqlicense.sh -accept


###################################
## Install IBM MQ, RDQM, Pacemaker, and DRBD
###################################
./Advanced/RDQM/installRDQMsupport


###################################
## Make this installation the primary installation.
###################################
# /opt/mqm/bin/setmqinst -i -p /opt/mqm


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

###################################
## Clean the system of RHEL subscription
## and run oci cleanup script.
##
## subscription-manager remove --all
## subscription-manager unregister
## subscription-manager clean
##
## wget -P /tmp https://raw.githubusercontent.com/oracle/oci-utils/master/libexec/oci-image-cleanup
## chmod 700 /tmp/oci-image-cleanup
## sudo /tmp/oci-image-cleanup -f
####################################
