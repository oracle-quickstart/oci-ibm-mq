
resource "oci_core_instance" "node" {
  count               = var.num_mq_pairs * 2
  display_name        = "${var.mq_node_hostname_prefix}-${floor(count.index/2)}-${count.index % 2}"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  fault_domain        = "FAULT-DOMAIN-${count.index % 3 + 1}"
  shape               = var.vm_compute_shape

  source_details {
    source_id   = local.compute_image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = local.bastion_subnet_id
    hostname_label   = "${var.mq_node_hostname_prefix}-${floor(count.index/2)}-${count.index % 2}"
    display_name     = "${var.mq_node_hostname_prefix}-${floor(count.index/2)}-${count.index % 2}"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(
      join(
        "\n",
        [
          "#!/usr/bin/env bash",
          "MQ_URL=\"${local.mq_url}\"",
          "NFS_SERVER_IP=\"${var.rm_only_ha_vip_private_ip}\"",
          "CREATE_QUEUE_MANAGER=\"${var.create_queue_manager}\"",
          "QUEUE_MANAGER_PREFIX=\"${var.queue_manager_prefix}\"",
          file("./scripts/configure.sh"),
        ],
      )
    )
  }

}
