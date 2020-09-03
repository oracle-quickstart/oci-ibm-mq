###
# compute.tf outputs
###

output "instance_public_ip" {
  value = join(", ", oci_core_instance.node.*.public_ip)
}

output "instance_private_ip" {
  value = join(", ", oci_core_instance.node.*.private_ip)
}
