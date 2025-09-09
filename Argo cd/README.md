Общие шаги от KUBERNETES 1-19.
Далее 20 - Развертывание абсолютно такое же, только публикация не HELM. а Argo CD приложение.

20.1 Установка Argo CD
	в кластере перейти на вкладку Marketplace
	Доступные для установки приложения -> Argo CD

    Пространство имен - std-int-005-06-kuber-diplom-momo-store
    Дождаться зеленого статуса - Deployed

![Argo CD](img/1.png?raw=true "Title")

20.2 Получите пароль администратора (admin):

    kubectl get secret argocd-initial-admin-secret \
    --output jsonpath="{.data.password}" | base64 -d
        Zx1HTWE6qmE-oAOi

![Argo CD](img/7.png?raw=true "Title")

20.3 Вспоминаю какой адрес у данной ВМ, нужен позже когда с локального компьютера подкючаюсь к данной удаленной ВМ
	
     curl ifconfig.me
		  62.84.119.105

20.4 Для доступа к приложению через localhost - Включите на ВМ port forward:
	
     kubectl port-forward service/argo-cd-argocd-server 8080:443

![Argo CD](img/8.png?raw=true "Title")

20.5 теперь чтобы подключиться на Argo CD надо с локальной машины подключиться к этому порту.
Чтобы подключиться к порту надо в начале подключиться к данной ВМ.
Чтобы подключьться к ВМ надо сделать ключ.
(Если ключ уже ранее делали, то он автоматически подтянется к данной ВМ)

![Argo CD](img/14.png?raw=true "Title")

    20.5.1 Делаю ключ для подключения к ВМ, с локального компьютера
    		ssh-keygen -t ecdsa -b 256
    			указал путь и имя файла куда сохранить ключ - C:/A/temp/yandex/git pelmen/ssh-key
    
    20.5.2 Теперь содержимое открытого ключа C:/A/temp/yandex/git pelmen/ssh-key.pub - я вношу в ВМ.
    		Compute Cloud - зайти в ВМ - Добавить новый SSH ключ. Если добавляли, то система автоматически подтянет все ранее подключенные SSH ключи

20.5.3 С локальной станции подключаю локальный порт 8080 к удаленному 8080, с указанием местоположения закрытого ключа, пользователь yndingo
	21.5.3.1 Открыть терминал/Powershell
	21.5.3.2 выполнить команду ниже, на запрос "Are you sure you want to continue connecting" ответить "yes"
	
     ssh -i "C:/A/temp/yandex/git pelmen/ssh-key" -L 8080:127.0.0.1:8080 yndingo@62.84.119.105

![Argo CD](img/17.png?raw=true "Title")

20.6 На локальном компьютере, откуда установили соединение к удаленной ВМ - Открыть браузер, например chrome, и перейти по ссылке http://localhost:8080 и авторизуйтесь с учетными данными администратора. Пароль получен в №20.2.
	
     admin/Zx1HTWE6qmE-oAOi

![Argo CD](img/21.png?raw=true "Title")

20.7 В начале подключить репозиторий в Argocd
Settings - Repositories - connect repo

    VIA HTTPS
    	Type = HELM
    	Name = diplom repo
    	Project = уже настроен, просто выбираешь
    	Repository URL = https://nexus.praktikum-services.tech/repository/std-int-005-006-helm-diplom/
    	Username = std-int-005-006
    	Password = 

![Argo CD](img/26.png?raw=true "Title")

![Argo CD](img/27.png?raw=true "Title")

20.8 подключаю приложение
Applications - new app / create application - edit as yaml - вставляю из application.txt (заранее подготовленный ямл) - save - create

https://github.com/yndingo/CI-CD/blob/main/Argo%20cd/application%20-%20Copy.txt

![Argo CD](img/28.png?raw=true "Title")

Выпуск сертификата примерно до 5 минут занимает, да бывает быстро за 1 минуту, но была один раз задержка на 5 минут.

![Argo CD](img/33.png?raw=true "Title")



