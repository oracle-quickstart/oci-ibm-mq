#!/usr/bin/env bash


###################################
## Get the installation binary and extraxct
###################################
cd ~
rm -rf MQServer
if ! -f IBM_MQ_9.1_LINUX_X86-64_TRIAL.tar.gz; then
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
. /opt/bin/setmqenv -s
if dspmqver ; then
  echo "Check...................1/1" 
else
  echo "Installation Failed"  
  exit
fi


###################################
## Verify server-to-server installation
###################################


###################################
## Verify client installation
###################################
