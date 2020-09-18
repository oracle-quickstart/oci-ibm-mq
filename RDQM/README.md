# RDQM 
These are Terraform modules that deploy IBM MQ RDQM configuration on Oracle Cloud Infrastructure (OCI). They are developed jointly by Oracle and IBM. 

## Prerequisites
1. First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle-quickstart/oci-prerequisites).

2. The compute image for the IBM MQ image is a custom image based off Oracle Linux 7.7. It has Red Hat Compatible Kernel (RHCK) and a few minor changes to the Linux kernel configuration. In order for this README to work, users will need to [download the custom image](https://objectstorage.us-ashburn-1.oraclecloud.com/p/HBb6fQS2Yg_lNVtX7WR-G8YlinMKixxdUkBzeZROo6w/n/partners/b/bucket-20200513-1843/o/OracleLinux7.7-RHCK-limits.conf) and put it into their tenancy as a custom image. ***Users will need to refer to the OCID of this custom image in the terraform code.***

For reference, the changes made to the standard Oracle Linux 7.7 image can be describes as follows:

    ## Set the GRUB 2 boot loader to load RHCK at reboot.
    $> grubby --set-default /boot/vmlinuz-3.10.0-1062.12.1.el7.x86_64
    
    ## Add the following lines to the /etc/security/limits.conf file.
    echo '* - nofile 10240'
    echo 'root - nofile 10240'

## Clone the Module
Now, you'll want a local copy of this repo.  You can make that with the commands:

    $> git clone https://github.com/oracle-quickstart/oci-ibm-mq.git
    $> cd oci-ibm-mq
    $> ls

That should give you this:

![](./images/ls.png)

Modify the `compute.tf` file to refer to your custom image OCID downloaded from above.

![](./images/custom_ocid.png)

We now need to initialize the directory with the module in it.  This makes the module aware of the OCI provider.  You can do this by running:

    $> terraform init

This gives the following output:

![](./images/terraform_init.png)

## Deploy
Now for the main attraction.  Let's make sure the plan looks good:

    $> terraform plan

That gives:

![](./images/terraform_plan.png)

If that's good, we can go ahead and apply the deploy:

    $> terraform apply

You'll need to enter `yes` when prompted.  The apply should take two to three minutes.  Once complete, you'll see something like this:

![](./images/terraform_apply.png)

## Connect to the Cluster
When the `terraform apply` completed...

## SSH to a Node
These machines are using Oracle Linux 7.7.  The default login is opc.  You can SSH into the machine with a command like this:

    $> ssh -i ~/.ssh/oci opc@<public_ip_address>

Configuration is happening asyncronously, and is complete when cloud-init finishes. You can view status or debug deployments by investigating the cloud-init entries in the `/var/log/messages` file:

    $> sudo -i
    $> cd /var/logs
    $> grep cloud-init messages

![](./images/cloud-init.png)

## Run IBM MQ commands
Become user `root` to source the IBM MQ installation output the version of the IBMQ software:

    $> sudo -i
    $> . /opt/mqm/bin/setmqenv -s
    $> dspmqver
    
![](./images/IBMMQ_ver.png)

Check the status of other nodes in the cluster:

    $> rdqmstatus -n

![](./images/RDQM_status.png)

## View the Cluster in the Console
You can also login to the web console to view the IaaS that is running the cluster.

![](./images/console.png)

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    $> terraform destroy

You'll need to enter `yes` when prompted.  Once complete, you'll see something like this:

![](./images/terraform_destroy.png)
