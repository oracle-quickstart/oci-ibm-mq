
resource "oci_core_instance" "node" {
  display_name        = "${var.mq_node_hostname_prefix}${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  fault_domain        = "FAULT-DOMAIN-${count.index % 3 + 1}"
  shape               = var.vm_compute_shape

  source_details {
    source_id   = local.compute_image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public[0].id
    hostname_label   = "${var.mq_node_hostname_prefix}${count.index}"
    display_name     = "${var.mq_node_hostname_prefix}${count.index}"
    assign_public_ip = true
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
