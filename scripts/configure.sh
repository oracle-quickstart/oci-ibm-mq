set -x

SERVER_MOUNT_DIR=/mnt/nfsshare/exports
CLIENT_MOUNT_DIR=/mnt/nfsv4

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

  HOSTNAME=`hostname`
  PREFIX_PAIRNUM=${HOSTNAME%-*}
  PAIRNUM=${PREFIX_PAIRNUM##*-}
  export QUEUE_MANAGER_NAME=${QUEUE_MANAGER_PREFIX}_${PAIRNUM}
  export MQ_DIR=${CLIENT_MOUNT_DIR}/${QUEUE_MANAGER_NAME}

  if [[ `hostname` == *0 ]]; then

    ## If the default directory name already exists for whatever reason, keep 
    ## trying to make a new directory based on the current time stamp.
    while [ -d ${MQ_DIR} ]; do
      MQ_DIR=${CLIENT_MOUNT_DIR}/`date +"%h-%d-%Y-%H:%M:%S"`
      sleep 1
    done
    mkdir ${MQ_DIR}
    mkdir ${MQ_DIR}/logs
    mkdir ${MQ_DIR}/qmgrs
    ln -s ${MQ_DIR} /MQHA
    chown -R mqm:mqm /MQHA/
    chmod -R ug+rwx /MQHA/
    
    ## Create the queue manager on the nodes
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; crtmqm -ld /MQHA/logs -md /MQHA/qmgrs ${QUEUE_MANAGER_NAME} ; dspmqinf -o command ${QUEUE_MANAGER_NAME} > ${MQ_DIR}/qm.created.0'
    while [ ! -e ${MQ_DIR}/qm.created.1 ]; do
       sleep 10
    done
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x ${QUEUE_MANAGER_NAME}'
    touch ${MQ_DIR}/qm.started.0
  elif [[ `hostname` == *1 ]]; then
    while [ ! -e ${MQ_DIR}/qm.created.0 ]; do
       sleep 10
    done
    ln -s ${MQ_DIR} /MQHA
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; . ${MQ_DIR}/qm.created.0'
    touch ${MQ_DIR}/qm.created.1
    while [ ! -e ${MQ_DIR}/qm.started.0 ]; do
       sleep 10
    done
    sudo -E -u mqm bash -c '. /opt/mqm/bin/setmqenv -s ; strmqm -x ${QUEUE_MANAGER_NAME}'
  fi

  ## Some cleanup once the second node in complete.
  if [[ `hostname` == *1 ]]; then
    rm -f  ${MQ_DIR}/qm.created.* ${MQ_DIR}/qm.started.0
  fi
}

sudo setenforce 0

systemctl stop firewalld
systemctl disable firewalld

mount_nfs_server
install_ibmmq
if [ "$CREATE_QUEUE_MANAGER" = true ]; then
  create_queue_manager
fi
