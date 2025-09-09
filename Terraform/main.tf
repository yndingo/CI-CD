module "yandex_cloud_network" {
    source = "./modules/tf-yc-network"
}

module "yandex_vm_new" {
    source 	= "./modules/tf-yc-instance"
    subnet_id	= module.yandex_cloud_network.yandex_vpc_subnet_id
}
