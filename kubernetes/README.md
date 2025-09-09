Начиная с этого шага уже идут общие шаги, то есть HELM, Argo cd, мониторинг будут затрагивать здесь какие то настройки

https://momo.std-int-005-06.su - сайт развернут только на время проверки работы. Так как содержание инфраструктуры стоит денег. По текущим расчетам 6 842,88 ₽ в месяц

std-int-005-06.su - купленное доменное имя
momo - так назвал приложение, можно и без него, но на данный момент это указано в ингресс и ресурсном имени

https://yandex.cloud/ru/docs/managed-kubernetes/quickstart?from=int-console-empty-state

1. Создать СА с правами Editor
	
       Identity and Access Management - std-int-005-06-diplom-sa - editor(включает права viewer)
	    https://yandex.cloud/ru/docs/monitoring/security/	

![kubernetes](img/4.png?raw=true "Title")

2. Создать кластер Kubernetes - 6 842,88 ₽ в месяц
	
       Managed Service for Kubernetes
	    Имя - std-int-005-06-kuber-diplom
        Релизный канал - STABLE
       Вычислительные ресурсы - 2 vCPU / 8 ГБ RAM
       Публичный адрес - автоматически
	    Тип мастера - базовый 1 хост
       Облачная сеть - я обычно все подчищаю после поэтому создаю с нуля
		Создать сеть - Каталог и Имя = default -  галочка "Создать подсети"
	    Зона доступности - ru-central1-a
	    Подсеть - default-ru-central1-a

       Дождаться статус Running и HEALTHY

![kubernetes](img/8.png?raw=true "Title")

![kubernetes](img/12.png?raw=true "Title")

3. В созданном кластере создать группу узлов (рабочих нод) - Управление узлами - 2 161,38 ₽ в месяц

![kubernetes](img/0.png?raw=true "Title")
 
       Имя - std-int-005-06-kuber-diplom-uzel
	    Тип - фиксированный
	    Кол-во узлов - 1
	    Расширение размера группы, макс - 1
       Вычислительные ресурсы - Своя конфигурация
       Платформа - Intel Ice Lake
		vCPU - 2
		Гарантированная доля vCPU - 20%
		RAM - 5 ГБ
        Тип диска - HDD
	    Размер - 64 ГБ
	    Публичный адрес - автоматически
	    Группы безопасности - Без групп
	    Расположение - ru-central1-a 
	    Доступ - Доступ по OS Login

![kubernetes](img/19.png?raw=true "Title")

4. В созданном кластере создать пространство имен - Пространства имен

        Имя - std-int-005-06-kuber-diplom-momo-store

![kubernetes](img/24.png?raw=true "Title")

5. Compute Cloud

        После того как виртуальная машина (в пункте №3 рабочая нода) создалась надо зайти на ВМ в GUI и 
        5.1 убедиться что сервисный аккаунт стоит std-int-005-06-diplom-sa созданный ранее 
        5.2 добавить открытый SSH-ключ. Если добавляли ранее, то он уже добавлен. Взял его со студенческой виртуалки.
       5.3 Проверяю подключение - взяв строку подключения из данной ВМ
       ssh -l yndingo 62.84.119.105

![kubernetes](img/28.png?raw=true "Title")

6. устанавливаю Yandex Cloud CLI	
	
       официальный CLI для работы с Yandex Cloud
		curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
        source "/home/yndingo/.bashrc"

![kubernetes](img/33.png?raw=true "Title")

7. Подключаю ВМ к созданному кластеру в облаке - Managed Service for Kubernetes
	7.1 Открыть созданный кластер
	7.2 скопировать в нем из "Подключиться с помощью CLI Yandex Cloud" строку подключения и выполнить ее на ВМ

        yc managed-kubernetes cluster get-credentials --id cat2drg73mj2870ef1fa --external

![kubernetes](img/36.png?raw=true "Title")

7.3 установить дефолтный профиль
        
        yc config profile create default

![kubernetes](img/38.png?raw=true "Title")

8. Установить пространство имен по умолчанию
	
       kubectl config set-context --current --namespace=std-int-005-06-kuber-diplom-momo-store

9. Обновляю переменную kubeconfig в gitlab
	Лучше сделать статический конфиг для работы с конкретным моим кластером:

https://yandex.cloud/ru/docs/managed-kubernetes/operations/connect/create-static-conf

![kubernetes](img/41.png?raw=true "Title")

        yc managed-kubernetes cluster list

         export CLUSTER_ID=catfjj1gbca1tic62t1v

        yc managed-kubernetes cluster get --id $CLUSTER_ID --format json | \
        jq -r .master.master_auth.cluster_ca_certificate | \
        awk '{gsub(/\\n/,"\n")}1' > ca.pem

        nano sa.yaml
        
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: admin-user
          namespace: kube-system
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: admin-user
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: cluster-admin
        subjects:
        - kind: ServiceAccount
          name: admin-user
          namespace: kube-system
        ---
        apiVersion: v1
        kind: Secret
        type: kubernetes.io/service-account-token
        metadata:
          name: admin-user-token
          namespace: kube-system
          annotations:
            kubernetes.io/service-account.name: "admin-user"
        
        kubectl create -f sa.yaml

        SA_TOKEN=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | \
          grep admin-user-token | \
          awk '{print $1}') -o json | \
          jq -r .data.token | \
          base64 -d)
        
        MASTER_ENDPOINT=$(yc managed-kubernetes cluster get --id $CLUSTER_ID \
          --format json | \
          jq -r .master.endpoints.external_v4_endpoint)
        
        kubectl config set-cluster sa-test2 \
          --certificate-authority=ca.pem \
          --embed-certs \
          --server=$MASTER_ENDPOINT \
          --kubeconfig=test.kubeconfig
        
        kubectl config set-credentials admin-user \
          --token=$SA_TOKEN \
          --kubeconfig=test.kubeconfig
        
        kubectl config set-context default \
          --cluster=sa-test2 \
          --user=admin-user \
          --kubeconfig=test.kubeconfig
        
        kubectl config use-context default \
          --kubeconfig=test.kubeconfig

        Проверяю, что конфигурация настроена верно, выполняя команду:
        		kubectl get namespace --kubeconfig=test.kubeconfig

9.10 шифрую конфиг и создаю/заменяю переменную гитлаб "kubeconfig"
		
    cat test.kubeconfig | base64

![kubernetes](img/53.png?raw=true "Title")

10. обновляю DEV_HOST переменная гит-лаб, а именно IP адрес VM из Compute Cloud, тот к которому подключился ранее для работы.

        curl ifconfig.me
        		62.84.119.105

![kubernetes](img/58.png?raw=true "Title")

11. VPA отсутствует по дефолту в Kubernetes кластере и его надо устанавливать дополнительно.

        git clone https://github.com/kubernetes/autoscaler.git && \
        cd autoscaler/vertical-pod-autoscaler/hack && \
        ./vpa-up.sh

![kubernetes](img/60.png?raw=true "Title")

12. После установки VPA меняется текущая папка, поэтому возращаюсь в домашнюю директорию. Просто для удобства.
	
         cd ~

13. Создаю зону ДНС

        yc dns zone create --name std-int-005-06-diplom \
	    --zone std-int-005-06.su. \
	    --public-visibility=true

![kubernetes](img/68.png?raw=true "Title")

14. Делегируйте домен сервису Cloud DNS - надо у кого купили домен, в моем случае nic.ru установить DNS ns1.yandexcloud.net и ns2.yandexcloud.net. Делегирование может до 24 часов занять.
Проверить делегирование домена можно с помощью сервиса Whois или утилиты dig:

         dig +short NS std-int-005-06.su

15. Зарезервировать статический публичный IP-адрес

        yc vpc address create --external-ipv4 zone=ru-central1-a
			  51.250.89.252

![kubernetes](img/67.png?raw=true "Title")

16.1 Создаю ресурсную запись типа A в зоне, указывающую на публичный IP-адрес веб-сервера:

        yc dns zone add-records \
	--name std-int-005-06-diplom \
	--record "momo.std-int-005-06.su. 600 A 51.250.89.252"

![kubernetes](img/69.png?raw=true "Title")

16.2 Создаю ресурсную запись для ГРАФАНЫ типа A в зоне, указывающую на публичный IP-адрес веб-сервера:
	
      yc dns zone add-records \
	--name std-int-005-06-diplom \
	--record "grafana.std-int-005-06.su. 600 A 51.250.89.252"

16.3 Создаю ресурсную запись для ПРОМЕТЕЯ типа A в зоне, указывающую на публичный IP-адрес веб-сервера:
	
     yc dns zone add-records \
	--name std-int-005-06-diplom \
	--record "prometheus.std-int-005-06.su. 600 A 51.250.89.252"

17. Установка Ingress-контроллера NGINX
в кластере перейти на вкладку Marketplace
	Доступные для установки приложения -> Ingress NGINX

        Пространство имен — std-int-005-06-kuber-diplom-momo-store
        IP-адрес контроллера — купленный выше/ранее статический айпи адрес

![kubernetes](img/76.png?raw=true "Title")

18. Установка менеджера для сертификатов Let's Encrypt
https://yandex.cloud/ru/docs/managed-kubernetes/operations/applications/cert-manager-cloud-dns
	в кластере перейти на вкладку Marketplace
	Доступные для установки приложения -> cert-manager c плагином Yandex Cloud DNS ACME webhook

        Пространство имен — std-int-005-06-kuber-diplom-momo-store
        Адрес электронной почты - нужен нормальный, я указывал свой yndingo@yandex.ru
        Дождитесь перехода приложения в статус Deployed

![kubernetes](img/80.png?raw=true "Title")

19. Создайте ClusterIssuer

        nano http01-clusterissuer.yaml
  
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: http01-clusterissuer
        spec:
          acme:
            server: https://acme-v02.api.letsencrypt.org/directory
            email: yndingo@yandex.ru
            privateKeySecretRef:
              name: http01-clusterissuer-secret
            solvers:
            - http01:
                ingress:
                  class: nginx

	    kubectl apply -f http01-clusterissuer.yaml

![kubernetes](img/90.png?raw=true "Title")

20. ДЕПЛОЙ ПРИЛОЖЕНИЯ

	-----------------------------------------------------
	если вы пришли от сюда с HELM или ARGOCD,
	то деплой нужно делать от них.
	-----------------------------------------------------

20.1 Деплой от kubernetes
Изменяю в папке "kubernetes" файл ".gitlab-ci-kubernetes". Просто добавляю перенос строки или удаляю перенос строки (enter/delete) и пушу измения в гит. Это провоцирует сборку и деплой данной папки.

	после деплоя бекенда проверяю все ли создалось и работает
		kubectl get pods
		kubectl get secrets		
		kubectl get services
		kubectl get deployments
		kubectl get ingress

Выпуск сертификата примерно до 5 минут занимает, да бывает быстро за 1 минуту, но была один раз задержка на 5 минут.

![kubernetes](img/91.png?raw=true "Title")

21. Проверьте готовность сертификата, как будет "true" можно переходить на сайт

https://momo.std-int-005-06.su/catalog

Пока сертификат не готов при заходе на страницу будет ошибка - Вероятная угроза безопасности
	kubectl get certificate

предупреждения в работе (если есть) видны в events
	kubectl get events




![kubernetes](img/92.png?raw=true "Title")














