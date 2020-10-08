set -x

export MQ_NAME="QM1"
export NFS_SERVER_IP="10.0.3.200"
export SERVER_MOUNT_DIR=/mnt/nfsshare/exports
export CLIENT_MOUNT_DIR=/mnt/nfsv4

function mount_nfs_server {
  yum -y install nfs-utils
  mkdir -p ${CLIENT_MOUNT_DIR}
  mount -t nfs -o vers=4,defaults,noatime,bg,timeo=100,ac,actimeo=120,nocto,rsize=1048576,wsize=1048576,nolock,local_lock=none,proto=tcp,sec=sys,_netdev ${NFS_SERVER_IP}:${SERVER_MOUNT_DIR} ${CLIENT_MOUNT_DIR} 
}

## https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.ins.doc/q008640_.htm
function install_ibmmq {

  if [ ! -e mqadv_dev915_linux_x86-64.tar.gz ]; then
    wget -q https://objectstorage.us-ashburn-1.oraclecloud.com/p/WXTu55FWJ-1GCLzWc3p9003lEtQ5p-MCPE-vlr78Df2zMaS2RgsntP-BcOXB93Vb/n/partners/b/bucket-20200513-1843/o/mqadv_dev915_linux_x86-64.tar.gz 
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
    if [ -d ${CLIENT_MOUNT_DIR}/MQHA${MQ_INSTALL_NUMBER} ]; then
      rm -rf ${CLIENT_MOUNT_DIR}/MQHA${MQ_INSTALL_NUMBER}
    fi 
    mkdir ${CLIENT_MOUNT_DIR}/MQHA${MQ_INSTALL_NUMBER} 
    ln -s ${CLIENT_MOUNT_DIR}/MQHA${MQ_INSTALL_NUMBER} /MQHA
    if [ ! -d /MQHA/logs ]; then
      mkdir /MQHA/logs
    fi
    if [ ! -d /MQHA/qmgrs ]; then
      mkdir /MQHA/qmgrs
    fi
    chown -R mqm:mqm /MQHA/
    chmod -R ug+rwx /MQHA/
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ;  crtmqm -ld /MQHA/logs -md /MQHA/qmgrs QM1'
    sleep 30
  elif [[ `hostname` == *1 ]]; then
    sleep 30
    ln -s ${CLIENT_MOUNT_DIR}/MQHA${MQ_INSTALL_NUMBER} /MQHA
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; addmqinf -s QueueManager -v Name=QM1 -v Directory=QM1 -v Prefix=/var/mqm -v DataPath=/MQHA/qmgrs/QM1'
  fi

  
  if [[ `hostname` == *0 ]]; then
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x QM1'
    sleep 30
  elif [[ `hostname` == *1 ]]; then
    sleep 30
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x QM1'
  fi
}

sudo setenforce 0

systemctl stop firewalld
systemctl disable firewalld

mount_nfs_server
install_ibmmq
create_queue_manager
