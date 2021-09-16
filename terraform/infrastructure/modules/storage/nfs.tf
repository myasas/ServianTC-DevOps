resource "aws_efs_file_system" "storage_nfs" {
  creation_token = "${var.short_name}-storage-nfs"

  provisioned_throughput_in_mibps = 5
  throughput_mode                 = "provisioned"

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-storage-nfs"
  })
}

resource "aws_efs_mount_target" "storage_nfs" {
  count = var.vpc_az_size

  file_system_id  = aws_efs_file_system.storage_nfs.id
  subnet_id       = element(var.vpc_subnet_storage_ids, count.index)
  security_groups = [var.security_group_storage_id]
}
