какого типа хранилище для картинок использовать? 

    Стандартное. Разница между стоимостью невелика, а время доступа для онлайн-сервиса, вероятно, будет приемлемое только у стандартного

Для хранения картинок создал отдельный bucket s3

     - 	terraform-state-std-int-005-006-diplom
	Доступ на чтение объектов - публичный
	Макс. размер - 0.006 ГБ, я уже знаю какие объекты там будут храниться, поэтому беру размер по минимуму.
		место которое занято объектами в бакете не сразу обновляется.
	теперь ссылка на картинку будет вида https://storage.yandexcloud.net/terraform-state-std-int-005-006-diplom/***.jpg

найти на ос ubuntu все файлы где есть 8dee5a92281746aa887d6f19cf9fdcc7 это имя одной из картинок, которую я заменил, ищу есть ли еще они где то

    grep -rwHn 8dee5a92281746aa887d6f19cf9fdcc7
		cmd/api/dependencies/store.go:16
		cmd/api/dependencies/store.go:72
		cmd/api/app/app_test.go:55

следовательно в файлах "/backend/cmd/api/appapp_test.go" и "/backend/cmd/api/store.go" указаны ссылки на картинки

    https://res.cloudinary.com/sugrobov/image/upload/v1651932687/repos/momos/	https://res.cloudinary.com/sugrobov/image/upload/v1651932686/repos/momos/
    Эти ссылки заменяю на https://storage.yandexcloud.net/terraform-state-std-int-005-006-diplom/
    то есть было
    https://res.cloudinary.com/sugrobov/image/upload/v1651932687/repos/momos/8dee5a92281746aa887d6f19cf9fdcc7.jpg
    стало
    https://storage.yandexcloud.net/terraform-state-std-int-005-006-diplom/1.jpg

  
