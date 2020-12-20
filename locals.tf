locals {

  # Oracle-Linux-7.7-2020.01.28-0 image for ashburn-1 region.
  # See this list for proper image ocid for alternate regions:
  #    https://docs.cloud.oracle.com/en-us/iaas/images/image/0a72692a-bdbb-46fc-b17b-6e0a3fedeb23/
  #
  image = "ocid1.image.oc1.iad.aaaaaaaamspvs3amw74gzpux4tmn6gx4okfbe3lbf5ukeheed6va67usq7qq"

  # Logic to use AD name provided by user input on ORM or to lookup for the AD name when running from CLI
  ad = (var.ad_name != "" ? var.ad_name : data.oci_identity_availability_domain.ad.name)

  # Set the MQ_URL environment variable if we're attempting to install 9.2.0 (9.1.5 is baked into the image).
  mq_url = var.mq_version == "9.2.0" ? "https://objectstorage.us-ashburn-1.oraclecloud.com/p/v-KDQLjLOrMF9IbOZ1XXXK_c5ZdTxWQ0hEdw1V1ihtF6-UKvEg74gQJ_bPh_e4pW/n/partners/b/IBM/o/IBM_MQ_9.2.0_LINUX_X86-64_TRIAL.tar.gz" : ""

  # Logic to choose a custom image or a marketplace image.
  compute_image_id = var.mp_subscription_enabled ? var.mp_listing_resource_id : var.custom_image_id

  # Local to control subscription to Marketplace image.
  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0

  # Marketplace Image listing variables - required for subscription only
  listing_id               = var.mp_listing_id
  listing_resource_id      = var.mp_listing_resource_id
  listing_resource_version = var.mp_listing_resource_version

  storage_subnet_id                 = var.use_existing_vcn ? var.storage_subnet_id : element(concat(oci_core_subnet.storage.*.id, [""]), 0)
  bastion_subnet_id                 = var.use_existing_vcn ? var.bastion_subnet_id : element(concat(oci_core_subnet.public.*.id, [""]), 0)
  vcn_id                            = var.use_existing_vcn ? var.vcn_id : oci_core_virtual_network.nfs[0].id
}
