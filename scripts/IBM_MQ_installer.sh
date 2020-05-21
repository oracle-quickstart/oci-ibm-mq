#!/usr/bin/env bash
set -x

###################################
## Update to lateset version of prerequisite packages
###################################
# Prerequisites
sudo yum -y -q install  OpenIPMI-modalias.x86_64 OpenIPMI-libs.x86_64 \
                        libyaml.x86_64 PyYAML.x86_64 libesmtp.x86_64 \
                        net-snmp-libs.x86_64 net-snmp-agent-libs.x86_64 \
                        openhpi-libs.x86_64 libtool-ltdl.x86_64 perl-TimeDate.x86_64

rpm --import https://packages.linbit.com/package-signing-pubkey.asc

###################################
## Get the installation binary and extraxct
###################################
wget -q https://objectstorage.us-ashburn-1.oraclecloud.com/p/bb414wRolCqgCwbGva7PfjBSt2_qEESt_E5SgoQH8fo/n/partners/b/bucket-20200513-1843/o/IBM_MQ_9.1_LINUX_X86-64_TRIAL_OL.tar.gz
tar -xvzf IBM_MQ_9.1_LINUX_X86-64_TRIAL_OL.tar.gz


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
## Configure script for the RDQM firewall
###################################
/opt/mqm/samp/rdqm/firewalld/configure.sh


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
## Perform various setup and group assignments
## for the mqm user and the opc user.
###################################
## Set password for mqm user
echo Ibmmq123! | sudo passwd mqm --stdin

## Add user opc to the mqm group
usermod -g mqm opc

## Allow user mqm to run commands without password.
## Required for RDQM.
sudo usermod -G wheel mqm
sudo -u mqm "/opt/mqm/bin/crtmqm"    
sudo -u mqm "/opt/mqm/bin/dltmqm"
sudo -u mqm "/opt/mqm/bin/rdqmadm"
sudo -u mqm "/opt/mqm/bin/rdqmstatus"


## Clear the /var/mqm/rdqm.ini
mv /var/mqm/rdqm.ini /var/mqm/rdqm.ini.bak
 
## Define the Pacemaker cluster by editing the /var/mqm/rdqm.ini
#for n in `seq 1 $node_count`; do
  echo "Node:" >> /var/mqm/rdqm.ini
  echo "HA_Primary=$(host RDQM-node-0 | awk '{ print $4 }')" >> /var/mqm/rdqm.ini
#done

## Initialize the rdqm Pacemaker cluster.
rdqmadm -c

echo "" > ~opc/Hello_World.txt


## Enter the following command on each of the nodes that does NOT have secondary instances of the RDQM:
#crtmqm -sx [-fs FilesystemSize] qmname


###################################
## Implement passwordless ssh:
## 
##   https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q131120_.##
##
## This is goinf to require a post installation/instance creation
## script run as the mqm user on all 3 nodes.
###################################
# ssh-keygen -t rsa -f /home/mqm/.ssh/id_rsa -N ''
# ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub remote_node1_primary_address
# ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub remote_node1_alternate_address
# ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub remote_node2_primary_address
# ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub remote_node2_alternate_address
# ssh remote_node1_primary_address uname -n
# ssh remote_node1_alternate_address uname -n
# ssh remote_node2_primary_address uname -n
# ssh remote_node2_alternate_address uname -n


###################################
## Verify server-to-server installation
###################################


###################################
## Verify client installation
###################################

