ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР

Чтобы позволить клиентскому контейнеру Docker взаимодействовать с серверным контейнером Docker, основным методом является сетевое взаимодействие внутри Docker.

Сети Docker: Наиболее распространенным и рекомендуемым подходом является размещение контейнеров фронтенда и бэкенда в одной сети Docker. Это может быть определенная пользователем сеть мостов, созданная явно или неявно, управляемая Docker Compose.

    1. docker network create my_app_network
    2. docker run --network my_app_network --name backend_container_name backend_image
    3. docker run --network my_app_network --name frontend_container_name frontend_image
			
Обнаружение услуг:
			Находясь в одной сети, контейнеры могут взаимодействовать, используя имена своих служб (как определено в Docker Compose) или имена контейнеров (если выполняются отдельные команды Docker Run) в качестве имен хостов. Например, фронтенд может выполнять вызовы API к http://backend_container_name:port/api/endpoint.


ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР Backend

    Перейти в папку backend где находится Dockerfile для бекенд
	  cd /docker/momo-store/backend

	  export VERSION="0.0.1"
	  
	  docker build -t momo-store-backend:$VERSION --build-arg VERSION=$VERSION .

	  Можно проверить, что образ действительно создался
	      docker images
	  удалить не нужный образ 
	      docker rmi -f momo-store-backend:0.0.1
	  удалить контейнер backend
	      docker rm -f momo-store-backend
		      -f — forced, это принудительное убийство контейнера

создать внутреннюю сеть

    docker network create -d bridge momo-store-network

    информация по доступным сетям для докер контейнеров
	      docker network ls

запустить созданный образ бекенда
	    
     docker run --rm -d -p 8081:8081 --name=momo-store-backend --network=momo-store-network momo-store-backend:0.0.1
		    --rm нужен, чтобы контейнер автоматически удалился, после остановки.
		    -p <порт хоста>:<порт контейнера>
		    -p 9999:8080 будет отдавать страничку на порту 9999 хостовой машины
	      Поскольку запросы с фронтенда на путь /api перенаправляются на http://momo-store-backend:8081, то необходимо прокинуть порт 8081 для бэкенда наружу

      посмотреть работающие контейнеры	      
         docker ps
      посмотреть логи процесса внутри контейнера, записав в файл log.txt
	        docker logs -f momo-store-backend


ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР Frontend

      Перейти в папку frontend где находится Dockerfile для фронта
	        cd /home/student/diplom/docker/momo-store/frontend

      export VERSION="0.0.1" 
      docker build -t momo-store-frontend:$VERSION --build-arg VERSION=$VERSION .

      Можно проверить, что образ действительно создался
	        docker images
      удалить не нужный образ 
	        docker rmi -f momo-store-frontend:0.0.1
      удалить контейнер frontend
	        docker rm -f momo-store-frontend
		        -f — forced, это принудительное убийство контейнера.

        удалит неиспользуемые образы и остановленные контейнеры
	          docker system prune -a

запустить созданный образ фронта с удалением после остановки

      docker run --rm -d -p 80:80 --name=momo-store-frontend --network=momo-store-network momo-store-frontend:0.0.1
		      --rm нужен, чтобы контейнер автоматически удалился, после остановки.
		      -p <порт хоста>:<порт контейнера>
		      -p 9999:8080 будет отдавать страничку на порту 9999 хостовой машины
	    Поскольку запросы с фронтенда на путь /api перенаправляются на http://momo-store-backend:8081, то необходимо прокинуть порт 8081 для бэкенда наружу

      посмотреть работающие контейнеры
	docker ps
      посмотреть все контейнеры
      	docker ps -a
      запустить созданный образ фронта без удаления после остановки
      	docker run -d -p 80:80 --name=momo-store-frontend momo-store-frontend:0.0.1
      посмотреть логи процесса внутри контейнера, записав в файл log.txt
      	docker logs -f momo-store-frontend


здесь я проверяю доступен ли бекенд по указанному адресу контейнера, прописанному в конфиге nginx.
НО ПРИ ЭТОМ ЭТО НАДО ВЫПОЛНЯТЬ ВНУТРИ КОНТЕЙНЕРА FRONTEND
      	
	полазить в контейнере momo-store-frontend
		docker exec -it momo-store-frontend bash
		docker exec -it momo-store-frontend sh		
			curl http://momo-store-backend:8081
         работает proxy_pass http://momo-store-backend:8081;


![ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР](img/2.png?raw=true "Title")

![ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР](img/5.png?raw=true "Title")

![ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР](img/6.png?raw=true "Title")

