#Variables declared in this file must be declared in the marketplace.yaml

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

variable "mp_listing_id" {
  // default = "ocid1.appcataloglisting.oc1.."
  default     = ""
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_id" {
  // default = "ocid1.image.oc1.."
  default     = ""
  description = "Marketplace Listing Image OCID"
}

variable "mp_listing_resource_version" {
  // default = "1.0"
  default     = ""
  description = "Marketplace Listing Package/Resource Version"
}

############################
#  Compute Configuration   #
############################

variable "mq_node_hostname_prefix" {
  default     = "mq-node-"
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
  default     = 0
  description = "OCI Availability Domains: 0,1,2  (subject to region availability)"
}

variable "ssh_public_key" {
  description = "SSH Public Key"
}

############################
#  Network Configuration   #
############################


variable "vcn_id" {
  default = "ocid1.vcn.oc1.iad.amaaaaaaugt6wmqai5eyf7cylvrnhmwn6rvt3vjhzjhs2dce6qquhxrwuo3a"
}

variable "subnet_id" {
  default = "ocid1.subnet.oc1.iad.aaaaaaaa2trdxao3qxhmhg2cwzgqfdgcmohhjikqyz5zri4cpw46bn6j42eq"
}


############################
# Additional Configuration #
############################

variable "compartment_ocid" {
  description = "Compartment where infrastructure resources will be created"
}

variable "nsg_display_name" {
  description = "Network Security Groups - Name"
  default     = "simple-security-group"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  default     = "10.0.0.0/16"
}

variable "nsg_whitelist_ip" {
  description = "Network Security Groups - Whitelisted CIDR block for ingress communication: Enter 0.0.0.0/0 or <your IP>/32"
  default     = "0.0.0.0/0"
}
