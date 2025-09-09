Логи отображаются в дашборде графаны. Поэтому в начале ее надо установить

1. скачать https://gitlab.praktikum-services.ru/root/monitoring-tools/
   
Это все сделано на helm chart
Понадобится helm chart grafana

3. Внести изменения - вношу какой namespace использую
	
       grafana/values.yaml
      		namespace: std-int-005-06-kuber-diplom-momo-store
      		ingress:
      		  # для данного адреса надо создать отдельную ресурсную запись
      		  host: grafana.std-int-005-06.su
      		  # создастся автоматически
      		  secretName: grafana-std-int-005-006-k8s-tls-secret
      	grafana/templates/deployment.yaml
      		namespace: {{ .Release.Namespace }} -> 
      			namespace: {{ .Values.Namespace }}
      		resources:
                  requests:
                    cpu: 250m -> 200m - нагрузка небольшая
                    memory: 750Mi -> 300Mi - сервер слабый нехватает
      	grafana/templates/ingress.yaml
      		namespace: {{ .Release.Namespace }} -> 
      			namespace: {{ .Values.Namespace }}
      		spec:
      		rules:
      		  - host: "{{ .Release.Namespace }}-grafana.k8s.praktikum-services.tech" -> 
      				- host: "grafana.std-int-005-06.su"
      		ingressClassName: "nginx"
      	    Если еще хочешь добавить поддержку https/tls, то это добавить
      		annotations:
      		  kubernetes.io/ingress.class: "nginx"
      		  nginx.ingress.kubernetes.io/rewrite-target: /
      		 -> 
      		annotations:
      		  cert-manager.io/cluster-issuer: "http01-clusterissuer"
      		tls:
      		  - hosts:
      			  - "{{ .Values.ingress.host }}"
      		    secretName: {{ .Values.ingress.secretName }}
      	grafana/templates/pvc.yaml
      		namespace: {{ .Release.Namespace }} -> 
      			namespace: {{ .Values.Namespace }}
      	grafana/templates/services.yaml 
      		namespace: {{ .Release.Namespace }} -> 
      			namespace: {{ .Values.Namespace }}

4. Установить, я через гитлаб устанавливаю.

        Проверить, что все корректно установилось
        	https://grafana.std-int-005-06.su
        		Если TLS не сделан, то будет писать, что есть Вероятная угроза безопасности и даже может потребуется открыть окно в безопасном режиме и там смотреть, так как браузер не будет пускать.




Loki - логирование

Loki — это горизонтально масштабируемая, высокодоступная многопользовательская система агрегации и хранения логов, вдохновленная Prometheus. Loki индексирует не содержимое логов, а набор меток для каждого потока логов.

1. Создать Bucket S3 для Loki

        Object Storage - Бакеты
        По умолчанию публичный доступ к бакету выключен
        	yc storage bucket create --name std-int-005-06-diplom-bucket-s3 --default-storage-class standard --max-size 10737418240

![Loki](img/4.png?raw=true "Title")

2. Установка Loki
	в кластере перейти на вкладку Marketplace
	Доступные для установки приложения -> Loki

        Пространство имен - std-int-005-06-kuber-diplom-momo-store
        		Название приложения - loki
        		Имя бакета - std-int-005-06-diplom-bucket-s3

       Дождитесь перехода приложения в статус Deployed.

![Loki](img/6.png?raw=true "Title")

3. Чтобы узнать пространство имен и имя сервиса Loki gateway выполните команду:
	
       kubectl get service -A | grep distributed-gateway
        Результат:
        	test-namespace   loki-loki-distributed-gateway   ClusterIP   10.96.168.88   <none>   80/TCP    15m
        		от сюда беру - loki-loki-distributed-gateway

![Loki](img/11.png?raw=true "Title")

4. После развертывания Loki будет доступен (если не доступен, надо подождать до 10 минут, не сразу все связи налаживаются) внутри кластера Managed Service for Kubernetes по следующему адресу:
	
       http://loki-loki-distributed-gateway.std-int-005-06-kuber-diplom-momo-store.svc.cluster.local





Loki + Grafana - логирование

1. Открыть ранее установленную графану
	
       https://grafana.std-int-005-06.su/

2. Установить источник данных Loki
        
        Configuration - data sources - Add data source - выбрать Loki
        	Name - Loki
        	URL - http://loki-loki-distributed-gateway.std-int-005-06-kuber-diplom-momo-store.svc.cluster.local
        		полученный в предыдущем пункте
        	Save & test - должна появиться надпись "Data source connected and labels found"

![Loki](img/15.png?raw=true "Title")

3. Создать дашборд - Create dashboard

4. Добавить панель где будет отображаться логирование.

        Add a new panel
        Log browser - развернуть
        	1. Select labels to search in - pod
        	2. Find values for the selected labels - momo
        		если видно что данные есть
        	3. Log browser - {pod=~"momo-backend-.*"}
        		это выведет все логи по бекенду
        	4. Open visualization suggestions
        	5. Выбрать единственно доступный вариант
        	6. Справа - Panel options - Title - указать название панели "LOGS - momo-backend"
        	5. Apply
	
    	6. щелкнуть на название панели "LOGS - momo-backend" - More - Duplicate
    	7. На новой панели нажать на имя "LOGS - momo-backend" - Edit
    	8. Log browser - {pod=~"momo-frontend-.*"}
    		это выведет все логи по фронту
    	4. Справа - Panel options - Title - указать название панели "LOGS - momo-frontend"
    	5. Apply

![Loki](img/21.png?raw=true "Title")

5. Добавить панель где будет отображаться данные по количеству логов.

        Add a new panel
        	У меня графана не показывает никаких данных по "log volume", пробовал искать "grafana doesn't show log volume" - не нашел почему
        	оказывается есть возможность сделать самому такой.
        Add a new panel
        	1. Log browser - 
        sum by (loglevel) (
          count_over_time( 
            {pod=~"momo-backend-.*"}
            [$__interval]
          )
        )
        		это выведет количество логов по бекенду с агрегацией по времени
        	2. Legend - log volume - backend + frontend
        	3. Справа - Panel options - Title - указать название панели "log volume"
		
        	4. "+Query"
        	5. Log browser - 
        sum by (loglevel) (
          count_over_time( 
            {pod=~"momo-frontend-.*"}
            [$__interval]
          )
        )
        		это выведет количество логов по фронту с агрегацией по времени
        	6. Legend - log volume - frontend
        	7. Apply


![Loki](img/35.png?raw=true "Title")






