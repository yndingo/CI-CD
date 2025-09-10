Terraform - развертывание на платных ресурсах
<br>
другие версии терраформ с яндекс облаком работали проблемно, поэтому работаю с версией terraform_1.5.7
<br>
1. Создать СА с правами Editor
   
	    Identity and Access Management - std-int-005-06-diplom-sa - editor(включает права viewer)
	<br>
3. Создать новый ключ доступа в Сервисном аккаунте

        Зайти в СА std-int-005-06-diplom-sa - правый верхний угол в СА "+ Создать новый ключ" -> Создать статический ключ доступа
    	Описание - terraform_state_backup
    		Идентификатор ключа
    			...
    		Ваш секретный ключ
    			...

4. Создать бакет для хранения состояния  - Object Storage
   
        Имя - terraform-state-backup-std-int-005-006-diplom
        Макс. размер - 1гб
        доступ везде ограниченный

5. Я с ВМ яндекса создаю, поэтому создаю ВМ - Compute Cloud - 1 563,62 ₽ в месяц
<br><br>
5.1 Виртуальные машины - Создать Виртуальную машину

    Расширенная настройка
    Ubuntu 24.04
    Зона доступности ru-central1-a
    SSD 20ГБ
    Вычислительные ресурсы - Своя конфигурация
    vCPU - 2
    Гарантированная доля vCPU - 20%
    RAM - 2ГБ
    Сетевые настройки - создать сеть если удаляли
    Подсеть default-ru-central1-a
    Доступ - Доступ по OS Login
    
    Дополнительно
    	Сервисный аккаунт - std-int-005-06-diplom-sa
    		созданный в шаге 1.

5. После создания и переключения в статус "Running" подключиться на данную ВМ. Открыть ВМ в браузере, пролистать до "Подключиться с помощью SSH-клиента" и там будет указан адрес и команда для подключения
	
       ssh -l yndingo 51.250.14.92

6. Скачать Terraform из зеркала Yandex.Cloud
https://hashicorp-releases.yandexcloud.net/terraform/

	    wget "https://hashicorp-releases.yandexcloud.net/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip"

7. Установить архиватор
	
       sudo apt install unzip

8. Распаковать скаченный архив
	
       unzip terraform_1.5.7_linux_amd64.zip

9. Переименовать файл, для моего удобства
	
       mv terraform terraform_1.5.7

10. после того как скопировал программу надо установить права на запуск, например 0755
	
         chmod 755 terraform_1.5.7
	
11. проверить что выполнятся Terraform
	
         ./terraform_1.5.7 -version

![terraform](img/2.png?raw=true "Title")

12. скопировать файлы terraform из моего проекта
<br>

![terraform](img/3.png?raw=true "Title")

13. в "state.config" внести имя бакета, созданного ранее
	
         bucket = "terraform-state-backup-std-int-005-006-diplom"

14. посмотреть айди облака и папки
	
         cloud-pelmen ...
        	default ...

15. в terraform.tfvars обновить эти айди
	
         cloud_id  = "..."
        	folder_id = "..."

16.	в tr_rc_location.tfrc указать текущую папку, там указано расположение файла terraformrc
	
         export TF_CLI_CONFIG_FILE="/home/yndingo/terraformrc"

    	The host "registry.terraform.io" given in provider source address
        │ "registry.terraform.io/yandex-cloud/yandex" does not offer a Terraform provider registry.
    	данная ошибка как раз относится к проблеме с tr_rc_location.tfrc
    		если в файле все указано верно, значит выполнить вручную команду в файле tr_rc_location.tfrc в консоли ВМ 

17. устанавливаю Yandex Cloud CLI	
	
		curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
	
18. инициализировать yc
	
         yc init
		https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb
	
18.1 В браузере где авторизован в https://console.yandex.cloud - открыть новую вкладку и скопировать строку подключения полученную в предыдущем пункте и вставить ее в эту вкладку
	
     получишь токен который ввести в консоль ВМ
    		y0__xCx8sBkGMHdEyDp6rmsFJjseergkgilTliM50H7m6Yeb9pM
    			далее выбрать облако (их получали в №14)
    			папку (их получали в №14)
    			зону для подключения - ru-central1-a
	
19. Проверьте, что профиль яндекс облака работает
Если вывод содержит список облаков - настройка прошла успешно
	
         yc resource-manager cloud list

![terraform](img/8.png?raw=true "Title")

20. вывести токен IAM чтобы потом его записать в файл
	
         echo $(yc iam create-token)
	
21. внести данный токен в secret.tfvars

        Он действует 12 часов.
 
22. инициализировать провайдера и инициализация backend s3 используя ключи в строке запуска
(эти ключи access_key и secret_key получены в №2)
	
         используя кастомный файл состояния state.config
        		./terraform_1.5.7 init -reconfigure -backend-config=state.config -backend-config="access_key=..." -backend-config="secret_key=..."
	
	    Если идет ошибка - Error: Invalid provider registry host │ The host "registry.terraform.io" given in provider source address
		значит выполнить вручную команду в файле tr_rc_location.tfrc в консоли ВМ

![terraform](img/9.png?raw=true "Title")
 
23. Сгенерировать SSH ключ, так как при развертывании в новую ВМ сразу интегрируется существующий SSH ключ "id_ecdsa.pub" с текущей ВМ
	
         ssh-keygen -t ecdsa -b 256
        		все по умолчанию сделать, 3 раза Enter нажать

![terraform](img/11.png?raw=true "Title")

24. проверка синтаксиса, если исползуется S3 bucket возможно придется реинициализировать
	
         ./terraform_1.5.7 validate

25. предварительная проверка с подключением
	
         ./terraform_1.5.7 plan -var-file=secret.tfvars

26. применение настроек
	
         ./terraform_1.5.7 apply -var-file=secret.tfvars
        		написать "yes" для подтверждения создания конфигурации в облаке

![terraform](img/13.png?raw=true "Title")

27. проверяю подключение к созданной машине в облаке под дефолтным пользователем ubuntu
	
         ssh ubuntu@10.128.0.7

![terraform](img/14.png?raw=true "Title")
 
28. проверяю подключение к созданной машине в облаке под дополнительным пользователем ansible

        ssh ansible@10.128.0.7

30. удалить созданную конфигурацию
	./terraform_1.5.7 destroy -var-file=secret.tfvars
