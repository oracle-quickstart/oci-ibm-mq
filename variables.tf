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
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
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
