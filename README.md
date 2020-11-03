# IBM MQ
These are Terraform modules that deploy [IBM MQ](https://www.ibm.com/products/mq) nodes on Oracle Cloud Infrastructure. They are developed jointly by Oracle and IBM.

## Resource Manager Deployment
This Quick Start uses [OCI Resource Manager](https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) to make deployment easy, sign up for an [OCI account](https://cloud.oracle.com/en_US/tryit) if you don't have one, and just click the button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://console.us-ashburn-1.oraclecloud.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-ibm-mq/archive/master.zip) 

Note, if you use this template to create another repo you'll need to change the link for the button to point at your repo.

## Local Development
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle-quickstart/oci-prerequisites).

## Clone the Module
Now that the prerequisites are out of the way, you'll want a local copy of this repo.  You can make that with the commands:

    $> git clone https://github.com/oracle-quickstart/oci-ibm-mq.git
    $> cd oci-ibm-mq
    $> ls

That should give you this:

![](./images/ls.png)

Rename the `provider.tf.cli` to `provider.tf`:
 
    $> mv provider.tf.cli provider.tf
    
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

## Connect to an MQ NODE
When the `terraform apply` completes you can SSH into the one of the nodes of the IBM MQ cluster:

    $> ssh -i ~/.ssh/oci opc@<public_ip_address>

Configuration is happening asyncronously, and is complete when cloud-init finishes. You can view status or debug deployments by investigating the cloud-init entries in the `/var/log/messages` file:

    $> sudo -i
    $> cd /var/logs
    $> grep cloud-init messages

![](./images/cloud-init.png)

## Run IBM MQ commands
Source the IBM MQ installation script and display the version of the IBMQ software:

    $> . /opt/mqm/bin/setmqenv -s
    $> dspmqver
    
![](./images/IBMMQ_ver.png)

Check the status of the active and standy nodes:

    $> dspmq -x

![](./images/MQ_status.png)

## Test the installation

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    $> terraform destroy

You'll need to enter `yes` when prompted.  Once complete, you'll see something like this:

![](./images/terraform_destroy.png)
