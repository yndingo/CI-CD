output "yandex_vpc_subnets" {
  description = "Yandex.Cloud Subnets map"
  value       = data.yandex_vpc_subnet.default
}

output "yandex_vpc_subnet_id" {
  description = "Yandex.Cloud Subnet id"
  value       = data.yandex_vpc_subnet.default.subnet_id
}