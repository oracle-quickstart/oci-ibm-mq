set -x

export NFS_SERVER_IP="10.0.3.200"
export SERVER_MOUNT_DIR=/mnt/nfsshare/exports
export CLIENT_MOUNT_DIR=/mnt/nfsv4

function mount_nfs_server {
  yum -y install nfs-utils
  mkdir -p ${CLIENT_MOUNT_DIR}
  mount -t nfs -o vers=4,defaults,noatime,bg,timeo=100,ac,actimeo=120,nocto,rsize=1048576,wsize=1048576,nolock,local_lock=none,proto=tcp,sec=sys,_netdev ${NFS_SERVER_IP}:${SERVER_MOUNT_DIR} ${CLIENT_MOUNT_DIR}

  ## Do not exit the mount function until the mount is complete
  mountpoint ${CLIENT_MOUNT_DIR}
  while [[ $? -eq 1 ]]; do
      echo sleeping 30...
      sleep 30s
      mountpoint ${CLIENT_MOUNT_DIR}
  done 
}

## https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.ins.doc/q008640_.htm
function install_ibmmq {

  cd ~opc
  if [[ ! -z $MQ_URL ]]; then
    ## MQ_URL is defined. So download the installer
    rm *.tar.gz
    wget -q $MQ_URL
    tar -xzf ${MQ_URL##*/}
  else
    tar -xzf mqadv_dev915_linux_x86-64.tar.gz
  fi
  cd MQServer
  ./mqlicense.sh -accept
  rpm -ivh MQSeries*.rpm
  /opt/mqm/bin/setmqinst -i -p /opt/mqm
}

## https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.con.doc/q018300_.htm
function create_queue_manager {

  if [[ `hostname` == *0 ]]; then
    if [ -d ${CLIENT_MOUNT_DIR}/MQHA ]; then
      rm -rf ${CLIENT_MOUNT_DIR}/MQHA
    fi 
    mkdir ${CLIENT_MOUNT_DIR}/MQHA
    ln -s ${CLIENT_MOUNT_DIR}/MQHA /MQHA
    if [ ! -d /MQHA/logs ]; then
      mkdir /MQHA/logs
    fi
    if [ ! -d /MQHA/qmgrs ]; then
      mkdir /MQHA/qmgrs
    fi
    chown -R mqm:mqm /MQHA/
    chmod -R ug+rwx /MQHA/
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ;  crtmqm -ld /MQHA/logs -md /MQHA/qmgrs QM1'
    sleep 65
  elif [[ `hostname` == *1 ]]; then
    sleep 65
    ln -s ${CLIENT_MOUNT_DIR}/MQHA /MQHA
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; addmqinf -s QueueManager -v Name=QM1 -v Directory=QM1 -v Prefix=/var/mqm -v DataPath=/MQHA/qmgrs/QM1'
  fi

  
  if [[ `hostname` == *0 ]]; then
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x QM1'
    sleep 65
  elif [[ `hostname` == *1 ]]; then
    sleep 65
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x QM1'
  fi
}

sudo setenforce 0

systemctl stop firewalld
systemctl disable firewalld

mount_nfs_server
install_ibmmq
create_queue_manager
