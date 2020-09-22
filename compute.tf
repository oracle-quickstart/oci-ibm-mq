
locals {
  ad = var.availability_domain_number >= 0 ? data.oci_identity_availability_domains.availability_domains.availability_domains[max(0, var.availability_domain_number)]["name"] : var.availability_domain_name

  # Oracle-Linux-7.7-2020.01.28-0 image for ashburn-1 region.
  # See this list for proper image ocid for alternate regions:
  #    https://docs.cloud.oracle.com/en-us/iaas/images/image/0a72692a-bdbb-46fc-b17b-6e0a3fedeb23/
  #
  platform_image = "ocid1.image.oc1.iad.aaaaaaaamspvs3amw74gzpux4tmn6gx4okfbe3lbf5ukeheed6va67usq7qq"

  # Logic to choose platform or mkpl image based on var.enabled
  image = var.enabled ? var.mp_listing_resource_id : local.platform_image
}

resource "oci_core_instance" "node" {
  display_name        = "mq-node-${count.index}"
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
    hostname_label   = "mq-node-${count.index}"
    display_name     = "mq-node-${count.index}"
    #private_ip       = join(".", concat(slice(split(".", var.starting_ip), 0, 3), [element(split(".", var.starting_ip), 3) + count.index]))
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    #user_data           = base64encode(file("./scripts/configure.sh"))
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
