ЛОКАЛЬНЫЙ ЗАПУСК ДОКЕР-КОМПОУЗ

Запуск приложения с помощью docker compose можно разбить на три шага:
    
    1. Формируются Dockerfile's для каждого компонента приложения.
    2. Приложения описываются в файле docker-compose.yml.
    3. Выполняется команда docker compose up.

Формирую Dockerfile's для каждого компонента приложения

	export VERSION="0.0.1"
	backend
		docker build -t momo-store-backend:$VERSION --build-arg VERSION=$VERSION /home/student/diplom/docker/momo-store/backend/
	frontend
		docker build -t momo-store-frontend:$VERSION --build-arg VERSION=$VERSION /home/student/diplom/docker/momo-store/frontend/

Можно проверить, что образ действительно создался
	
     docker images

запускаю сборку docker compose, для проверки работы, если будет ошибка ее наглядно будет видно

     docker compose up

запускаю сборку docker compose в detach режиме
  
     docker compose up -d


     
