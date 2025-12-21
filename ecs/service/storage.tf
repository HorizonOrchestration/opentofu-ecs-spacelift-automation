# ------------------------------------------------------------------------------
# Storage Resources
# ------------------------------------------------------------------------------

resource "aws_efs_access_point" "config" {
  for_each = {
    for container in var.container_definitions : container.name => container
  }
  file_system_id = var.efs_file_system_id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/${var.task_name}-${each.key}-persistent-config"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}
