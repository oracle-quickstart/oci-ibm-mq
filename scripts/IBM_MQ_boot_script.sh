#!/usr/bin/env bash
set -x


##################################
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

## Clear the /var/mqm/rdqm.ini and define the Pacemaker cluster
##
##   https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q130290_.htm
if [ -f /var/mqm/rdqm.ini ] ; then mv /var/mqm/rdqm.ini /var/mqm/rdqm.ini.bak ; fi
for n in 0 1 2; do
  echo "Node:" >> /var/mqm/rdqm.ini
  echo "HA_Replication=$(host RDQM-node-${n} | awk '{ print $4 }')" >> /var/mqm/rdqm.ini
done
rdqmadm -c


## Any firewall must allow traffic between the nodes on a range of ports.
/opt/mqm/samp/rdqm/firewalld/configure.sh


## If the system uses SELinux in a mode other than permissive, you must run the following command:
semanage permissive -a drbd_t
