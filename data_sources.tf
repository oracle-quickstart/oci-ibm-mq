data "oci_core_images" "ol7" {
  compartment_id   = "${var.compartment_ocid}"
  operating_system = "Oracle Linux"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
  state            = "AVAILABLE"

  # filter restricts to OL 7
  filter {
    name   = "operating_system_version"
    values = ["7\\.[0-9]"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.compartment_ocid
}



#data "oci_core_subnet" "private_storage_subnet" {
#  subnet_id = var.storage_subnet_id
#}

#data "oci_core_subnet" "private_fs_subnet" {
#  subnet_id = var.subnet_id
#}

#data "oci_core_subnet" "public_subnet" {
#  subnet_id = var.subnet_id
#}

#data "oci_core_vcn" "nfs" {
#  vcn_id = var.vcn_id 
#}


