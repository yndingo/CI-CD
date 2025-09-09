provider "yandex" {
  cloud_id	= var.cloud_id
  folder_id	= var.folder_id
  token	= var.IAMtoken
  zone	= module.yandex_vm_new.zone_out
}

