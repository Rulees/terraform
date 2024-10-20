# Outputs
output "boot_disk_ids" {
  description = "The IDs of the boot disks created for the instances."
  value = {
    for disk in yandex_compute_disk.boot_disk :
    disk.name => disk.id
  }
}

output "secondary_disk_ids_by_zone" {
  description = "The IDs of the secondary disks by zone."
  value = {
    "ru-central1-a" = { for disk in yandex_compute_disk.secondary_disk_a : disk.name => disk.id }
    "ru-central1-b" = { for disk in yandex_compute_disk.secondary_disk_b : disk.name => disk.id }
    "ru-central1-d" = { for disk in yandex_compute_disk.secondary_disk_d : disk.name => disk.id }
  }
}

output "instance_ids" {
  description = "The IDs of the Yandex Compute instances."
  value = {
    for instance in yandex_compute_instance.this :
    instance.name => instance.id # Вывод: ключ(instance.name) = значение(instance.id)
  }
}

output "instance_public_ip_addresses" {
  description = "The external IP addresses of the instances."
  value = {
    for address in yandex_vpc_address.this :
    address.name => address.external_ipv4_address[0].address
  }
}

output "subnet_ids" {
  description = "The IDs of the VPC subnets used by the Yandex Compute instances."
  value = {
    for cidr_block, subnet_info in module.net.public_subnets :
    subnet_info.name => subnet_info.subnet_id
  }
}

output "ydb_id" {
  description = "The ID of the Yandex Managed Service for YDB instance."
  value       = yandex_ydb_database_serverless.this.id
}

output "service_account_id" {
  description = "The ID of the Yandex IAM service account."
  value       = module.s3.storage_admin_service_account_id
}

output "bucket_name" {
  description = "The name of the Yandex Object Storage bucket."
  value       = module.s3.bucket_name
}

output "serial_port_files" {
  description = "The Serial port's output files."
  value = [
    for instance in yandex_compute_instance.this :
    "serial_output_${instance.name}.txt"
  ]
}