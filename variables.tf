#Variables declared in this file must be declared in the marketplace.yaml

module "nfs" {
  source            = "https://objectstorage.us-ashburn-1.oraclecloud.com/n/marketplaceprod/b/oracleapps/o/orchestration%2F85482691%2Fnfs.zip"
  tenancy_ocid      = var.tenancy_ocid
  compartment_ocid  = var.compartment_ocid
  region            = var.region
  ssh_public_key    = var.ssh_public_key
  use_existing_vcn  = "true"
  storage_subnet_id = oci_core_subnet.storage[0].id
  fs_subnet_id      = oci_core_subnet.fs[0].id
  bastion_subnet_id = oci_core_subnet.public[0].id
  vcn_id            = oci_core_virtual_network.nfs[0].id
  ad_name           = local.ad
  client_node_count = 0
  rm_only_ha_vip_private_ip = "10.0.3.200"
  persistent_storage_server_shape = "VM.Standard2.4"
  storage_tier_1_disk_count = "4"
  storage_tier_1_disk_size = "100" 
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

variable mount_point { 
  default = "/mnt/nfs" 
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.2" //2 cores
}

variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain"
}

variable "availability_domain_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

variable "ssh_public_key" {
  description = "SSH Public Key"
}

############################
#  Network Configuration   #
############################

variable "network_strategy" {
  #default = "Use Existing VCN and Subnet"
  default = "Create New VCN and Subnet"
}

variable "use_existing_vcn" {
  default = "false"
}

variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "storage_subnet_id" {
  default = ""
}

############################
# Additional Configuration #
############################

variable "compartment_ocid" {
  description = "Compartment where infrastructure resources will be created"
}

######################
#    Enum Values     #
######################
variable "network_strategy_enum" {
  type = map
  default = {
    CREATE_NEW_VCN_SUBNET   = "Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET = "Use Existing VCN and Subnet"
  }
}
