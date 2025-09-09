resource "yandex_compute_image" "ubuntu" {
    source_family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_disk" "boot-disk-vm-1" {
    name	= "boot-disk-vm-1"
    type	= "network-ssd"
    zone 	= var.zone
    size	= 20
    image_id	= yandex_compute_image.ubuntu.id
}

resource "yandex_compute_instance" "vm-1" {
    name = "std-int-005-006-diplom"

    zone = var.zone
    # виды физических процессоров    
    platform_id = var.platform_id

    # Конфигурация ресурсов:
    # количество процессоров и оперативной памяти
    resources {
        cores  = var.cpu_num
        memory = var.cpu_ram
    }

    # Загрузочный диск:
    # здесь указывается образ операционной системы
    # для новой виртуальной машины
    boot_disk {
        disk_id = yandex_compute_disk.boot-disk-vm-1.id
    }

    # Сетевой интерфейс:
    # нужно указать идентификатор подсети, к которой будет подключена ВМ
    network_interface {
        subnet_id = var.subnet_id
    # здесь разрешаем или не разрешаем (false) доступ в интернет
        nat       = true
    }

    # Метаданные машины:
    # здесь можно указать скрипт, который запустится при создании ВМ
    # или список SSH-ключей для доступа на ВМ
    metadata = {
       ssh-keys = "ubuntu:${file("~/.ssh/${var.ssh_filename}")}"
    # создать пользователя и группы в созданной машине
       user-data = templatefile("${path.module}/${var.init_yml_filename}",
	{ ssh-key = file("~/.ssh/${var.ssh_filename}") } )
    }
}

