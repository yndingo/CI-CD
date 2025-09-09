output "ip_address" {
#айпи адрес ВМ
    value = module.yandex_vm_new.ip_address
}

output "yandex_cloud_network_subnet_id" {
#используется для визуального контроля
    value = module.yandex_cloud_network.yandex_vpc_subnet_id
}

output "yandex_cloud_network" {
#используется для визуального контроля
    value = module.yandex_cloud_network.yandex_vpc_subnets
}


