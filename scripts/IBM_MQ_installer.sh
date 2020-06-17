#!/usr/bin/env bash
set -x

###################################
## Update to lateset version of prerequisite packages
###################################
# Prerequisites
systemctl stop firewalld
systemctl disable firewalld

cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo "*                hard   nofile         10240" >> /etc/security/limits.conf
echo "*                soft   nofile         10240" >> /etc/security/limits.conf
echo "root             hard   nofile         10240" >> /etc/security/limits.conf
echo "root             soft   nofile         10240" >> /etc/security/limits.conf

yum -y -q install  OpenIPMI-modalias.x86_64 OpenIPMI-libs.x86_64 \
                        libyaml.x86_64 PyYAML.x86_64 libesmtp.x86_64 \
                        net-snmp-libs.x86_64 net-snmp-agent-libs.x86_64 \
                        openhpi-libs.x86_64 libtool-ltdl.x86_64 perl-TimeDate.x86_64
rpm --import https://packages.linbit.com/package-signing-pubkey.asc


###################################
## Get the installation binary and extraxct
###################################
wget -q https://objectstorage.us-ashburn-1.oraclecloud.com/p/N4IfEfvPm5yfj8SjAgJNL8DKgnSWb-TM-2YxfcoTFZ0/n/partners/b/bucket-20200513-1843/o/mqadv_dev915_linux_x86-64-OL.tar.gz
touch mqadv_dev915_linux_x86-64-OL.tar.gz
tar -xzf mqadv_dev915_linux_x86-64-OL.tar.gz


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
## Perform various setup and group assignments
## for the mqm user and the opc user.
###################################
## Set password for mqm user
echo Ibmmq123! | sudo passwd mqm --stdin


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
## Each node requires a volume group named drbdpool. The 
## storage for each replicated data queue manager is 
## allocated as a separate logical volume per queue manager 
## from this volume group. For the best performance, this 
## volume group should be made up of one or more physical 
## volumes that correspond to internal disk drives (preferably SSDs). 
## You should create drbdpool after you have installed the 
## RDQM HA solution, but before you actually create any RDQMs. 
## Check your volume group configuration by using the vgs command. 
## The output should be similar to the following:
##
##  VG       #PV #LV #SN Attr   VSize   VFree 
##  drbdpool   1   9   0 wz--n- <16.00g <7.00g
##
##  https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q130980_.htm
##
###################################
## Create a Volume group called drbdpool
echo "Attempting iscsi discovery/login of 169.254.2.2 ..."
success=1
while [[ $success -eq 1 ]]; do
  iqn=$(iscsiadm -m discovery -t sendtargets -p 169.254.2.2:3260 | awk '{print $2}')
  if  [[ $iqn != iqn.* ]] ;
  then
    echo "Warning: unexpected iqn value: $iqn. Waiting 10sec."
    sleep 10s
    continue
  else
    echo "Success for iqn: $iqn"
    success=0
  fi
done
iscsiadm -m node -o update -T $iqn -n node.startup -v automatic
iscsiadm -m node -T $iqn -p 169.254.2.2:3260 -l
sleep 5

## Assuming 1 block volume at the 169.254.2.2 ip address
vg_path=`ls /dev/disk/by-path/ip-169.254.2.2*`
pvcreate ${vg_path}
vgcreate drbdpool ${vg_path} 


## You must configure sudo so that the mqm user can run the following commands with root authority:
usermod -G wheel mqm
usermod -G haclient mqm
usermod -G haclient root
usermod -a -G mqm root

## Clear the /var/mqm/rdqm.ini and define the Pacemaker cluster
##
##   https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q130290_.htm
if [ -f /var/mqm/rdqm.ini ] ; then mv /var/mqm/rdqm.ini /var/mqm/rdqm.ini.bak ; fi
for n in 0 1 2; do
  echo "Node:" >> /var/mqm/rdqm.ini
  echo "HA_Replication=$(host RDQM-node-${n} | awk '{ print $4 }')" >> /var/mqm/rdqm.ini
done
rdqmadm -c


###################################
## If there is a firewall between the nodes in the HA group, 
## then the firewall must allow traffic between the nodes on 
## a range of ports. A sample script is provided, /opt/mqm/samp/rdqm/firewalld/configure.sh, 
## that opens up the necessary ports if you are running the 
## standard firewall in RHEL. You must run the script as root. 
## If you are using some other firewall, examine the service definitions 
## /usr/lib/firewalld/services/rdqm* to see which ports need to be opened.
###################################
#/opt/mqm/samp/rdqm/firewalld/configure.sh


## Enter the following command on each of the nodes that does NOT have secondary instances of the RDQM:
## https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q130310_.htm
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
