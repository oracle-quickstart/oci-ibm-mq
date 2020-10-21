#Variables declared in this file must be declared in the marketplace.yaml

module "nfs" {
  source            = "https://objectstorage.us-ashburn-1.oraclecloud.com/n/marketplaceprod/b/oracleapps/o/orchestration%2F85482691%2Fnfs.zip"
  tenancy_ocid      = var.tenancy_ocid
  compartment_ocid  = var.compartment_ocid
  region            = var.region
  ssh_public_key    = var.ssh_public_key
  use_existing_vcn  = "true"

  storage_subnet_id = local.storage_subnet_id 
  fs_subnet_id      = local.storage_subnet_id
  bastion_subnet_id = local.bastion_subnet_id
  vcn_id            = local.vcn_id

  ad_name           = local.ad
  client_node_count = 0
  rm_only_ha_vip_private_ip = var.rm_only_ha_vip_private_ip 
  persistent_storage_server_shape = "VM.Standard2.4"
  storage_tier_1_disk_count = var.storage_tier_1_disk_count
  storage_tier_1_disk_size = var.storage_tier_1_disk_size
}

variable "mq_url" {
  default     = ""
}

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {
}

variable "region" {
}

############################
#  Marketplace Image      #
############################

variable "custom_image_id" {
  default     = ""
  description = "Custom Image OCID"
}

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = true
}

variable "mp_listing_id" {
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaavsl2ivajgog5fkagcixvnckrycfaw2uogpp5hbgh6emj7zou3vpa"
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_id" {
  default     = "ocid1.image.oc1..aaaaaaaa7fqtftixxzcxclxmdbfvk2ko6rmq5jnc6jk77wq7xjm5ijo2qahq"
  description = "Marketplace Listing Image OCID"
}

variable "mp_listing_resource_version" {
  default     = "9.1"
  description = "Marketplace Listing Package/Resource Version"
}

############################
#  Compute Configuration   #
############################

variable "num_mq_pairs" {
  default = 1
  description = "The number is mq mode pairs to be spun up."
}

variable "mq_node_hostname_prefix" {
  default = "mq-node"
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.2" //2 cores
}

variable "ad_name" {
  default     = ""
  description = "Availability Domain"
}

variable "ad_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

variable "ssh_public_key" {
  default = ""
  description = "SSH Public Key"
}

############################
#  Network Configuration   #
############################

variable "use_existing_vcn" {
  default = "false"
}

variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "rm_only_ha_vip_private_ip" {
  default = "10.0.3.200"
}

variable "vcn_id" {
  default = ""
}

variable "bastion_subnet_id" {
  default = ""
}

variable "storage_subnet_id" {
  default = ""
}

############################
#  Network Configuration   #
############################

variable "storage_tier_1_disk_count" {
  default = "4"
  description = "Number of block volume disk for entire filesystem (not per file server). If var.fs_ha  was set to true, then these Block volumes will be shared by both NFS file servers,        otherwise a single node NFS server will be deployed with Block volumes. Block volumes are more durable and highly available."
}

variable "storage_tier_1_disk_size" {
  default = "100"
  description = "Select size in GB for each block volume/disk, min 50.  Total NFS filesystem raw capacity will be NUMBER OF BLOCK VOLUMES * BLOCK VOLUME SIZE."
}

############################
# Additional Configuration #
############################

variable "compartment_ocid" {
  description = "Compartment where infrastructure resources will be created"
}
