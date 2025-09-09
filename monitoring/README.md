скачать https://gitlab.praktikum-services.ru/root/monitoring-tools/

Это все сделано на helm chart
Понадобится helm chart prometheus
потребовалось внести изменения в бекенд - для исправлениея расчет азадержки

1. Внести изменения - вношу какой namespace использую

        prometheus/values.yaml
      		namespace: std-int-005-06-kuber-diplom-momo-store
      		ingress:
      		  # для данного адреса надо создать отдельную ресурсную запись
      		  host: prometheus.std-int-005-06.su.std-int-005-06.su
      		  # создастся автоматически
      		  secretName: prometheus.std-int-005-06.su-std-int-005-006-k8s-tls-secret
      	prometheus/templates/configmap.yaml
      		namespace: {{ .Release.Namespace }}
      		и - {{ .Release.Namespace }}
      		-> 
      		namespace: {{ .Values.namespace }}
      		и - {{ .Values.namespace }}
    		
    		еще добавил Работу "kubelet" возможно для анализа по https Ноды
    		- job_name: kubelet
    		  kubernetes_sd_configs:
    		  - role: node
    		  scheme: https
    		  metrics_path: /metrics
    		  tls_config:
    			insecure_skip_verify: true
    			ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    		  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    		  relabel_configs:
    		  - source_labels: [__address__]
    			regex: '(.*):10250'
    			replacement: '${1}:10250'
    			target_label: __address__
    		
    		Чтобы начать собирать метрики про отдельные контейнеры ("метрики Cadvisor"), нужно добавить в конфигурацию prometheus ещё одну секцию для скрейпинга
    		- job_name: 'kubelet-cadvisor'
    		  kubernetes_sd_configs:
    			- role: node
    		  scheme: https
    		  metrics_path: /metrics/cadvisor
    		  tls_config:
    			ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    			insecure_skip_verify: true
    		  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    		  relabel_configs:
    			- source_labels: [__address__]
    			  regex: '(.*):10250'
    			  replacement: '${1}:10250'
    			  target_label: __address__		
    		
    	prometheus/templates/deployment.yaml
    		namespace: {{ .Release.Namespace }}
    		-> 
    		namespace: {{ .Values.namespace }}
    		resources:
                limits:
                  cpu: 1 -> 200m - нагрузка небольшая
                  memory: 1Gi -> 256Mi - нагрузка небольшая
    	prometheus/templates/ingress.yaml
    		namespace: {{ .Release.Namespace }} -> 
    			namespace: {{ .Values.Namespace }}
    		spec:
    		rules:
    		  - host: "{{ .Release.Namespace }}-grafana.k8s.praktikum-services.tech" -> 
    				- host: "{{ .Values.ingress.host }}"
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
    	prometheus/templates/rules.yaml
    		namespace: {{ .Release.Namespace }} -> 
    			namespace: {{ .Values.Namespace }}
    	prometheus/templates/services.yaml 
    		namespace: {{ .Release.Namespace }} -> 
    			namespace: {{ .Values.Namespace }}

4. Установить, я через гитлаб устанавливаю.
Проверить, что все корректно установилось

	https://prometheus.std-int-005-06.su

		Если TLS не сделан, то будет писать, что есть Вероятная угроза безопасности и даже может потребуется открыть окно в безопасном режиме и там смотреть, так как браузер не будет пускать.

6. Добавить сервисный аккаунт для prometheus с правами на просмотр ресурсов
Установить RBAC (Role-Based Access Control) для prometheus
Надо помнить что сервисный аккаунт облака std-int-005-06-diplom-sa не имеет никакого отношения к сервисному аккаунту кластера кубернетес

6.1 Создать файл

nano rbac-Role-and-Binding.yaml

    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: pod-lister-role
      namespace: std-int-005-06-kuber-diplom-momo-store
    rules:
      - apiGroups: [""] # Для core-группы ресурсов
        resources:
          - nodes # Доступ к данным узлов
          - nodes/metrics # Доступ к метрикам узлов
          - services # Доступ к сервисам
          - pods # Доступ к подам
        verbs: ["get", "list", "watch"] # Глаголы действий над ресурсами
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: pod-lister-binding
      namespace: std-int-005-06-kuber-diplom-momo-store
    subjects:
    - kind: ServiceAccount
      name: default # Refers to the 'default' service account in the 'std-int-005-06-kuber-diplom-momo-store' namespace
      namespace: std-int-005-06-kuber-diplom-momo-store
    roleRef:
      kind: Role
      name: pod-lister-role
      apiGroup: rbac.authorization.k8s.io

6.2 Применить файл
	
kubectl apply -f rbac-Role-and-Binding.yaml

6.3 Создать файл
	
nano rbac-Role-and-Binding2.yaml

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cluster-wide-node-metrics-access
    rules:
      - apiGroups: [""] # Для core-группы ресурсов
        resources:
          - nodes # Доступ к данным узлов
          - nodes/metrics # Доступ к метрикам узлов
          - services # Доступ к сервисам
          - pods # Доступ к подам
          - endpoints # добавляю анализ metric server
        verbs: ["get", "list", "watch"] # Глаголы действий над ресурсами
      - nonResourceURLs: ["/metrics"] # Непрофильный путь для сбора метрик
        verbs: ["get"] # Только метод GET доступен для этого маршрута
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: bind-clusterwide-node-metrics-access
    subjects:
      - kind: ServiceAccount
        name: default
        namespace: std-int-005-06-kuber-diplom-momo-store
    roleRef:
      kind: ClusterRole
      name: cluster-wide-node-metrics-access
      apiGroup: rbac.authorization.k8s.io

6.4 Применить файл
	
kubectl apply -f rbac-Role-and-Binding2.yaml

7. Проверить, что появился Сервисный аккаунт в кубернетес

Managed Service for Kubernetes - Кластеры - открыть нужный кластер - управление доступом
	
       В сервисных аккаунтах выбрать зону/пространство имен "std-int-005-06-kuber-diplom-momo-store"
      		там должна быть сервисная запись "default"
      		а справа должны быть 2 роли в моем случае
      			pod-lister-role (std-int-005-06-kuber-diplom-momo-store)
      			cluster-wide-node-metrics-access

![prometheus](img/14.png?raw=true "Title")

![prometheus](img/15.png?raw=true "Title")

![prometheus](img/16.png?raw=true "Title")

![prometheus](img/17.png?raw=true "Title")

8. перезапустить Под прометея, без этого Сервисный аккаунт default не сможет корректно взаимодействовать с ресурсами

        kubectl get pods
        	prometheus-6f468dbf4d-6v4km
        kubectl delete pod prometheus-6f468dbf4d-4wz94
        kubectl get pods - после удаления сразу создастся новый под
        	prometheus-6f468dbf4d-6v4km
        kubectl logs prometheus-6f468dbf4d-6v4km
        	проверить, что в логах нет ошибок подключения и/или ошибок взаимодействия







МОНИТОРИНГ

prometheus + grafana

1. Открыть ранее установленную графану
	https://grafana.std-int-005-06.su/
	
2. Установить источник данных Prometheus
Configuration - data sources - Add data source - выбрать Prometheus
	
       Name - Prometheus
      	URL - http://prometheus:9090
      	Save & test - должна появиться надпись "Data source connected and labels found"

![prometheus](img/24.png?raw=true "Title")

3. Прометей забирает данные из экспортера данных. В моем случае им выступает бекенд.

4. Создать дашборд - Create dashboard

6. Добавить панель где будет отображаться 1й золотой сигнал - задержка
Add a new panel
Log browser - ввести

        histogram_quantile(0.90,
          sum by (le, kubernetes_pod_name, handler) (
            rate(
              response_timing_ms_bucket[5m]
            )
          )
        )
   
7.1 Справа - Panel options - Title - указать название панели "Задержка обработки запросов, 90%%, микросек"

7.2 Apply

потребовалось внести изменения в бекенд, для получения рабочей гистограммы

    \momo-store\backend\cmd\api\app\middleware.go
    
    // TimingsMiddleware records timings of app handlers
    func (i *Instance) TimingsMiddleware(next http.Handler) http.Handler {
    	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    		start := time.Now()
    		next.ServeHTTP(w, r)		
    		i.responseTimings.
    			With(map[string]string{"handler": r.URL.Path}).
    			Observe(float64(time.Since(start).Milliseconds()))
    	})
    }
    
    проблема в сборе метрик для гистограммы - время ответа так мало, что в миллисекундах всегда будет ноль
    Надо получать время в микросекундах.
    Milliseconds -> Microseconds
    
    \momo-store\backend\cmd\api\app\app.go
    	Buckets: prometheus.LinearBuckets(0, 50, 10),
    
    //измерение перешло в микросекунды
    Buckets: prometheus.ExponentialBuckets(0.01, 2, 12),
    0.01мс=10мкрс
    	- Линейное распределение подходит для случаев, когда ожидаемые временные характеристики довольно однородны и сконцентрированы вокруг небольшого промежутка времени (например, десятки или сотни миллисекунд).
    	- Экспоненциальное же позволяет охватывать гораздо больший диапазон задержек, особенно полезно, если наблюдается широкий разброс времен отклика: от микросекундных операций до секундных ожиданий.
    
    LinearBuckets(0, 50, 10) -> ExponentialBuckets(0.01, 2, 12)


8. Добавить панель где будет отображаться 2й золотой сигнал - трафик
   
8.1 Add a new panel

8.2 Log browser - ввести

        sum(
        	increase( requests_count[5m] )
        )
	
        Применяй rate(), если важно оценить интенсивность потока событий (среднюю частоту происходящих действий).
        Используй increase(), если нужен общий прирост за определённый период

8.3 Legend - auth / products / cart

8.4 Справа - Panel options - Title - указать название панели "Трафик всех запросов к бекенду (количество за 5 минут)"

8.5 Apply


8.6 Add a new panel

8.7 Log browser - ввести

      sum by (instance) (
      increase(
      	dumplings_listing_count{ id="1" }[5m]
      	)
      )

    Я ограничиваю вывод только адресом бекенда и анализирую только пельмени с id="1", так как они все одновременно выводятся, поэтому нет смысла их все анализировать.
    Используй increase(), если нужен общий прирост за определённый период

8.8 Справа - Panel options - Title - указать название панели "Количество заходов на главную страницу сайта за 5 минут"

8.9 Apply

9. 3й золотой сигнал - количество ошибок не получится вывести, так как единственно что нашел это rest_client_requests_total с кодами обращений, но при обращении к ошибочному адресу https://momo.std-int-005-06.su/catalog3 на фронте идет 404 не найдено, но rest_client_requests_total{code="404" - количество не растет









10. Добавить панели где будут отображаться 4й золотой сигнал - насыщение ЦПУ
    
10.1 Add a new panel

10.2 Log browser A - ввести

(сколько ЦПУ затратили контейнеры бекенда)

        sum by (container,pod) (
        	rate( container_cpu_usage_seconds_total
        		{ container=~"^momo-back.*$" }[5m]
        	)
        )

10.3 Log browser B - ввести

(здесь я определяю предел доступности по ЦПУ бекенда)

      sum by(container,pod)
      	(container_spec_cpu_quota 
      	{ container=~"^momo-back.*$" }
      	) 
      /
      sum by(container,pod)
      	(container_spec_cpu_period 
      	{ pod=~"^momo-back.*$" }
      	)

    container_spec_cpu_period - длительность периода планирования
    container_spec_cpu_quota - сколько квантов времени в течение квоты доступно контейнеру

10.4 Legend - верхний лимит

10.5 Справа - Panel options - Title - указать название панели "Утилизация ЦПУ бекенд"

10.6 Apply








10.7 Add a new panel

10.8 Log browser A - ввести

(сколько ЦПУ затратили контейнеры фронта)

    sum by (container,pod) (
    	rate( container_cpu_usage_seconds_total
    		{ container=~"^momo-front.*$" }[5m]
    	)
    )

10.9 Log browser B - ввести

(здесь я определяю предел доступности по ЦПУ фронта)

    sum by(container,pod)
    	(container_spec_cpu_quota 
    	{ container=~"^momo-front.*$" }
    	) 
    /
    sum by(container,pod)
    	(container_spec_cpu_period 
    	{ pod=~"^momo-front.*$" }
    	)
    
    container_spec_cpu_period - длительность периода планирования
    container_spec_cpu_quota - сколько квантов времени в течение квоты доступно контейнеру

10.10 Legend - верхний лимит

10.11 Справа - Panel options - Title - указать название панели "Утилизация ЦПУ фронт"

10.12 Apply












11. Добавить панели где будут отображаться 4й золотой сигнал - насыщение ПАМЯТЬ

11.1 Add a new panel

11.2 Log browser A - ввести

(сколько памяти затратили контейнеры бекенда)

    sum by (pod) (
    	max_over_time( container_memory_max_usage_bytes
    		{ container=~"^momo-back.*$" }[5m]
    	)
    )
    / (1024 * 1024)

11.3 Log browser B - ввести

(максимальной предел доступной памяти для контейнеров бекенда)

    sum by(container,pod)
    	(container_spec_memory_limit_bytes 
    	{ container=~"^momo-back.*$" }
    	)
    	/ (1024 * 1024)
    
    Показатели утилизации памяти только лучше приводить не в байтах, а в мегабайтах или гигабайтах, чтобы не заставлять пользователя считать нули

11.4 Legend - верхний лимит

11.5 Справа - Panel options - Title - указать название панели "Утилизация памяти бекенд, МБ"

11.6 Apply






12.7 Add a new panel

12.8 Log browser A - ввести

(сколько памяти затратили контейнеры фронта)

    sum by (pod) (
    	max_over_time( container_memory_max_usage_bytes
    		{ container=~"^momo-front.*$" }[5m]
    	)
    )
    / (1024 * 1024)

12.9 Log browser B - ввести

(максимальной предел доступной памяти для контейнеров бекенда)

    sum by(container,pod)
    	(container_spec_memory_limit_bytes 
    	{ container=~"^momo-front.*$" }
    	)
    	/ (1024 * 1024)
    
    Показатели утилизации памяти только лучше приводить не в байтах, а в мегабайтах или гигабайтах, чтобы не заставлять пользователя считать нули

12.10 Legend - верхний лимит

12.11 Справа - Panel options - Title - указать название панели "Утилизация памяти фронт, МБ"

12.12 Apply

Нагрузку я генерирую с помощью специального инструмента JMeter

![prometheus](img/29.png?raw=true "Title")

![prometheus](img/33.png?raw=true "Title")

![prometheus](img/34.png?raw=true "Title")
