resource "yandex_vpc_network" "this" {
  name = "private"
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.this.id
}

resource "yandex_compute_disk" "boot-disk" {
  name     = "boot-disk"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8btqg2mh540ftne9p4"
  size     = 15
}

resource "yandex_compute_instance" "this" {
  name                      = "linux-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "arkselen:${file("~/.ssh/YC.pub")}"
  }
}

resource "yandex_ydb_database_serverless" "this" {
  name = "test-ydb-serverless"
}

resource "yandex_iam_service_account" "bucket" {
  name = "bucket-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = "b1g8a4ko3p44nba31fa7"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket.id}"
}

resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = yandex_iam_service_account.bucket.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "this" {
  bucket     = "terraform-bucket-${random_string.bucket_name.result}"
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key

  depends_on = [yandex_resourcemanager_folder_iam_member.storage_editor]
}

resource "random_string" "bucket_name" {
  length  = 8
  upper   = false
  special = false
}





















