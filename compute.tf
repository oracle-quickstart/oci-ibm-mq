
locals {
  ad = var.availability_domain_number >= 0 ? data.oci_identity_availability_domains.availability_domains.availability_domains[max(0, var.availability_domain_number)]["name"] : var.availability_domain_name

  # Oracle-Linux-7.7-2020.01.28-0 image for ashburn-1 region.
  # See this list for proper image ocid for alternate regions:
  #    https://docs.cloud.oracle.com/en-us/iaas/images/image/0a72692a-bdbb-46fc-b17b-6e0a3fedeb23/
  #
  image = "ocid1.image.oc1.iad.aaaaaaaamspvs3amw74gzpux4tmn6gx4okfbe3lbf5ukeheed6va67usq7qq"

}

resource "oci_core_instance" "node" {
  display_name        = "${var.mq_node_hostname_prefix}${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  fault_domain        = "FAULT-DOMAIN-${count.index % 3 + 1}"
  shape               = var.vm_compute_shape

  source_details {
    source_id   = local.image
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    hostname_label   = "${var.mq_node_hostname_prefix}${count.index}"
    display_name     = "${var.mq_node_hostname_prefix}${count.index}"
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(
      join(
        "\n",
        [
          "#!/usr/bin/env bash",
          file("./scripts/configure.sh"),
        ],
      )
    )
  }

  count = 2
}
