#!/usr/bin/env bash

###################################
## Get the installation binary and extraxct
###################################
cd ~
rm -rf MQServer
if ! [ -f IBM_MQ_9.1_LINUX_X86-64_TRIAL.tar.gz ] ; then 
  wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/ePOOE2C5JNcypPRKFemaP7h0uub4NH5FzJIuSwuKmwY/n/partners/b/bucket-20200513-1843/o/IBM_MQ_9.1_LINUX_X86-64_TRIAL.tar.gz
fi
tar -xvzf IBM_MQ_9.1_LINUX_X86-64_TRIAL.tar.gz


###################################
## Accept the software license 
###################################
cd MQServer
sudo ./mqlicense.sh -accept


###################################
## Install all IBM MQ components to the default location 
###################################
sudo rpm -ivh MQSeries*.rpm


###################################
## Verify local server installation
###################################
. /opt/mqm/bin/setmqenv -s
if dspmqver ; then 
  echo "Check...................1/1" 
else 
  echo "Installation Failed"  
  exit
fi


###################################
## Perform various setup and group assignments
## for the mqm user and the opc user.
###################################
## Set password for mqm user
echo Ibmmq123! | sudo passwd mqm --stdin

## Add opc to the mqm group
usermod -g mqm opc


###################################
## Implement passwordless ssh:
## 
##   https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q131120_.htm
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

