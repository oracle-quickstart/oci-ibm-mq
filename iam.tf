provider "oci" {
  alias  = "home_region"
  region = lookup(data.oci_identity_regions.home-region.regions[0], "name")
}


resource "oci_identity_dynamic_group" "ha_dynamic_group" {
  provider       = oci.home_region
  compartment_id = var.tenancy_ocid
  name           = "nfs_ha"
  description    = "Set up instance principle for HA NFS failover"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}' }"

}

resource "oci_identity_policy" "ha_iam_policy" {
  provider       = oci.home_region
  name           = "nfs_ha"
  description    = "Allows instances to use vnics, subnets and private-ips APIs"
  compartment_id = var.compartment_ocid
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.ha_dynamic_group.name} to use private-ips in compartment ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.ha_dynamic_group.name} to use vnics in compartment ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.ha_dynamic_group.name} to use subnets in compartment ${var.compartment_ocid}"
  ]

}
