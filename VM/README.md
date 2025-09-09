1. В начале надо создать свое первое яндекс облако.
	
 https://center.yandex.cloud

2. для установки ДНС имени через CLI нужен сервисный аккаунт

    -> Дополнительно ->
	  сервисный аккаунт - Создать аккаунт
	  имя - std-int-005-06-diplom-sa
    Роли в каталоге - Добавить роль - EDITOR - editor

3. Далее в этом созданном облаке "cloud-pelmen" - Compute Cloud - покупаю Виртуальную Машину
	
 https://console.yandex.cloud

Предалагаю ориентироваться на следующие характеристики

    ОС последняя доступная версия Ubuntu 24.04
	  Зона доступности - ru-central1-a
	  диск ssd 20gb
    Вычислительные ресурсы - своя конфигурация 2CPU, доля 20%, 5ГБ ОЗУ - хватит, чтобы развернуть мониторинг и прочие сервисы, ЦПУ практически не испольузется
     Подсеть - по умолчанию
	  Публичный IP-адрес - автоматически
    Доступ - Доступ по OS Login - безопасное подключение с помощью SSH-сертификатов или SSH-ключей
    Ориентировочная цена 2 216,81 ₽ в месяц, оплата взымается почасовая.

4. После того как машина создалась надо зайти на ВМ и добавить открытый SSH-ключ. Взял его со студенческой виртуалки.

5. Подключаюсь по внешнему IP адресу используя SSH ключ

6.0 Чтобы получить доступ к именам из публичной зоны, вам нужно делегировать домен. Укажите адреса серверов ns1.yandexcloud.net и ns2.yandexcloud.net в личном кабинете вашего регистратора.

6.1 1й способ назначить доменное имя для ВМ - через GUI
	https://yandex.cloud/ru/docs/dns/operations/resource-record-create#console_1

6.1.1 Открываю Cloud DNS
6.1.2 Выбираю зону из списка или создаю
	если создавать, там же будет видна стоимость создания зоны - 128,46 ₽ в месяц
	
	Зона - "std-int-005-06.su."
		значение должно заканчиваться на точку "."
	Тип - Публичная
		Доменные имена в публичных зонах доступны из интернета
	Имя - std-int-005-06-diplom

6.1.3 Создаю ресурсную запись. Проваливаюсь в зону. Записи -> Создать запись.
	
     Имя - совпадает с именем зоны
	Тип - А
	Значение - выбираю из выпадающего меню, внешний IP адрес, в моем случае 62.84.115.208
	TTL (в секундах) - 600

6.1.4 YC (Yandex Cloud CLI) ставить не обязательно.
	
     Обновление DNS 30-60 секунд примерно.
	Проверить
		ping std-int-005-06.su
			пингуемый адрес должен совпадать с внешним адресом ВМ

6.2 2й способ назначить доменное имя для ВМ - через CLI 
ПОДКЛЮЧЕНИЕ К ЯНДЕКС ОБЛАКУ CLI для назначения доменного имени

6.2.1 Yandex Cloud CLI Установка - Это установит утилиту yc - официальный CLI для работы с Yandex Cloud
	curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

6.2.2 нужно, чтобы bash перечитал .bashrc 

    Там задаётся переменная PATH, которая используется для поиска выполнимых файлов, и которую модифицирует процесс установки yc
	source "/home/ввести имя пользователя/.bashrc"
		В моем случае я подключился под пользователем yndingo
		source "/home/yndingo/.bashrc"

    yc (Yandex Cloud) на этой виртуалке должен автоматически получать iam-токен из метадаты инстанса

6.2.3 Создаю зону ДНС
	
     yc dns zone create --name std-int-005-06-diplom \
	--zone std-int-005-06.su. \
	--public-visibility=true

6.2.4 Делегируйте домен сервису Cloud DNS - надо у кого купили домен, в моем случае nic.ru установить DNS ns1.yandexcloud.net и ns2.yandexcloud.net. Делегирование может до 24 часов занять.
Проверить делегирование домена можно с помощью сервиса Whois или утилиты dig:

     dig +short NS std-int-005-06.su

6.2.5 Создаю ресурсную запись типа A в зоне, указывающую на публичный IP-адрес веб-сервера:

    yc dns zone add-records \
	--name std-int-005-06-diplom \
	--record "std-int-005-06.su. 600 A 158.160.101.171"

7. Для развертывания через docker-compose в начале надо Docker
	
       sudo apt-get update
	    sudo apt-get install ca-certificates curl gnupg lsb-release
	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	    sudo apt-get update
	    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

8. Добавим текущего пользователя в docker group:
	
       sudo groupadd docker
	    sudo usermod -aG docker $USER
		после данного шага надо перезайти/выйти и заново залогиниться в систему. Если не перезайти все команды докер надо будет через SUDO выполнять.
			exit
			ssh yndingo@62.84.115.208

10. Проверить что docker/Докер работает
	
         docker info

11. перед деплоем docker-compose надо обновить параметры в gitlab

        DEV_HOST = std-int-005-06.su
	    DEV_USER = yndingo
	    SSH_KNOWN_HOSTS - получается командой - на каждой новой ВМ он будет новым.
		ssh-keyscan std-int-005-06.su |& grep -v '^#'
		данные для переменной гитлаб SSH_KNOWN_HOSTS

Как удалить созданные ресурсы
Чтобы перестать платить за созданные ресурсы:
    Удалите ВМ.
    Удалите статический публичный IP-адрес, если вы зарезервировали его специально для этой ВМ.
    Удалите созданную доменную зону.
