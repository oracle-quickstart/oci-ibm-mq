resource "oci_core_volume" "NodeVolume" {
  # node count hard coded at 3 and not exposed as a var
  count               = 3 * var.disk_count
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  display_name        = "volume-${count.index}"
  size_in_gbs         = var.disk_size
}

resource "oci_core_volume_attachment" "NodeAttachment" {
  # node count hard coded at 3 and not exposed as a var
  count           = 3 * var.disk_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.node[count.index].id
  volume_id       = oci_core_volume.NodeVolume[count.index].id
}
