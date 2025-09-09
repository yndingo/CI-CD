output "ip_address" {
#ничего нового не узнаем, используется просто для визуального контроля правильности обработки
    description = "Публичный IP адрес виртуальной машины"
    value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "zone_out" {
#ничего нового не узнаем, используется просто для визуального контроля правильности обработки
    description = "вывод для основного блока"
    value = var.zone
}
