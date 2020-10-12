#Variables declared in this file must be declared in the marketplace.yaml

module "nfs" {
  source            = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/aLmgffTKuLlgVabFGyjlcI3-SARgGmbtthFUj6vvEWcNZi16P04fS1nsb44AgeeE/n/partners/b/bucket-20200513-1843/o/nfs.zip"
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

variable "mq_node_hostname_prefix" {
  default = "mq-node-"
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

variable "create_compute_nodes" { default = "true" }

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

variable "vcn_id" {
  default = ""
}

variable "vcn_display_name" {
  description = "VCN Name"
  default     = "simple-vcn"
}

variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "vcn_dns_label" {
  description = "VCN DNS Label"
  default     = "simplevcn"
}

variable "subnet_type" {
  description = "Choose between private and public subnets"
  default     = "Public Subnet"
  #or
  #default     = "Private Subnet"
}

variable "subnet_id" {
  default = ""
}

variable "subnet_display_name" {
  description = "Subnet Name"
  default     = "simple-subnet"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  default     = "10.0.0.0/24"
}

variable "subnet_dns_label" {
  description = "Subnet DNS Label"
  default     = "simplesubnet"
}

variable "storage_subnet_id" {
  default = ""
}

############################
# Security Configuration #
############################
variable "nsg_display_name" {
  description = "Network Security Group Name"
  default     = "simple-network-security-group"
}

variable "nsg_source_cidr" {
  description = "Allowed Ingress Traffic (CIDR Block)"
  default     = "0.0.0.0/0"
}

variable "nsg_ssh_port" {
  description = "SSH Port"
  default     = 22
}

variable "nsg_https_port" {
  description = "HTTPS Port"
  default     = 443
}

variable "nsg_http_port" {
  description = "HTTP Port"
  default     = 80
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

variable "subnet_type_enum" {
  type = map
  default = {
    PRIVATE_SUBNET = "Private Subnet"
    PUBLIC_SUBNET  = "Public Subnet"
  }
}

variable "nsg_config_enum" {
  type = map
  default = {
    BLOCK_ALL_PORTS = "Block all ports"
    OPEN_ALL_PORTS  = "Open all ports"
    CUSTOMIZE       = "Customize ports - Post deployment"
  }
}
