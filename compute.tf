locals {
  ad = var.availability_domain_number >= 0 ? data.oci_identity_availability_domains.availability_domains.availability_domains[max(0, var.availability_domain_number)]["name"] : var.availability_domain_name

  # RHEL 7.7
  platform_image = "ocid1.image.oc1.iad.aaaaaaaav5yg323zkdwaqlm45ddmvtauupem34pfve4wdknhwf36vlgzbxuq"

  # Logic to choose platform or mkpl image based on var.enabled
  image          = var.enabled ? var.mp_listing_resource_id : local.platform_image
}

resource "oci_core_instance" "node" {
  display_name        = "rdqm-node-${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  fault_domain        = "FAULT-DOMAIN-${count.index % 3 + 1}"
  shape               = var.vm_compute_shape

  source_details {
    source_id   = local.image
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.subnet_id : oci_core_subnet.public_subnet[0].id
    hostname_label   = "rdqm-node-${count.index}"
    display_name     = "rdqm-node-${count.index}"
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(file("./scripts/IBM_MQ_boot_script.sh"))
  }

  count = var.node_count
}
