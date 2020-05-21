resource "oci_core_volume" "NodeVolume" {
  count               = var.node_count * var.disk_count
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = "volume-${count.index}"
  size_in_gbs         = var.disk_size
}

resource "oci_core_volume_attachment" "NodeAttachment" {
  count           = var.node_count * var.disk_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.node[count.index].id
  volume_id       = oci_core_volume.NodeVolume[count.index].id
}
