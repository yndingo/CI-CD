variable "zone" {
  default     = "ru-central1-a"
  type        = string
  description = "Instance availability zone"
  validation {
    condition     = contains(toset(["ru-central1-a", "ru-central1-b", "ru-central1-d"]), var.zone)
    error_message = "Select availability zone from the list: ru-central1-a, ru-central1-b, ru-central1-d."
  }
  #sensitive = true #регулирует отображение параметра в консоли. Cкрывать зону размещения виртуалки
  nullable = false
}

variable "platform_id" {
    default     = "standard-v1"
    description = "Идентификатор платформы - Yandex Compute Cloud, предоставляет различные виды физических процессоров."
    type = string
}

variable "scheduling_policy" {
    default     = "true"
    description = "создавать ли прерываемую ВМ"
    type = string
}

variable "cpu_num" {
    default     = "2"
    description = "Количество ЦПУ в ВМ. Мы не знаем, какого размера виртуалка может понадобиться в будущем"
    type = number
}

variable "cpu_ram" {
    default     = "2"
    description = "Количество памяти в ВМ. Мы не знаем, какого размера виртуалка может понадобиться в будущем"
    type = number
}

variable "ssh_filename" {
    default     = "id_ecdsa.pub"
    description = "имя нужного ключа ССШ"
    type = string
}

variable "init_yml_filename" {
    default     = "user-group-init.yaml"
    description = "имя нужного ключа ССШ"
    type = string
}

variable "subnet_id" {
    description = "это подсеть из модуля сети, но используя корневой блок, а не модуль сети"
    type = string
}