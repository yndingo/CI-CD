Здесь я исправляю ошибки найденные с помощью SONARQUBE

GitLab для хранения кода, организации процесса сборки и доставки, хранения артефактов;

		https://gitlab.praktikum-services.ru/

Nexus для хранения артефактов сборки;

		https://nexus.praktikum-services.tech/

SonarQube для анализа кода.

		https://sonarqube.praktikum-services.ru/

1. Создал проект гитлаб

![gitlab](img/3.png?raw=true "Title")

2. Клонирую на локальную машину для доработки кода
	    git clone https://gitlab.praktikum-services.ru/std-int-005-006/momo-store.git	
3. Создал новую ветку docker-compose и запушил ее на сервер
    	git branch docker-compose
    	git push --set-upstream origin docker-compose
    	git checkout docker-compose
4. Создал
    	.gitlab-ci - запуск модульных пайплайнов
    	docker-compose.yml - вызывается модулями в блоках script
    	backend/.gitlab-ci-backend - модуль сборки бекенд
    	frontend/.gitlab-ci-frontend - модуль сборки фронта

подключаю Нексус для хранения артефактов
	    https://nexus.praktikum-services.tech/

![gitlab](img/14.png?raw=true "Title")
	
данные которые завести в гитлаб для подключения

  		NEXUS_REPO_URL = https://nexus.praktikum-services.tech
  		NEXUS_REPO_USER = std-int-005-006
  		NEXUS_REPO_PASS = 

![gitlab](img/15.png?raw=true "Title")

Завел 2 новых проекта - raw, для архива, параметры по умолчанию
  		std-int-005-006-backend-diplom
		std-int-005-006-frontend-diplom

Подключаю тесты
	    1. на сайте sonarqube.praktikum-services.ru создал 2 новых проекта для фронта и бекенда
	    2. на сайте gitlab.praktikum-services.ru в проекте диплома завел переменные для подключения к виртуальной машине и к sonarqube

      SONARQUBE_URL = https://sonarqube.praktikum-services.ru
      SONAR_PROJECT_KEY_BACKEND = 05_MuzafinII_backend_diplom
      SONAR_LOGIN_BACKEND = 
      SONAR_PROJECT_KEY_FRONTEND = 05_MuzafinII_frontend_diplom
      SONAR_LOGIN_FRONTEND = 

      DEV_USER = student

      SSH_PRIVATE_KEY = 
      SSH_KNOWN_HOSTS = 
          ssh-keyscan std-int-005-06.praktikum-services.tech |& grep -v '^#'

3. перед деплоем проверяю, что все выключено

4. добавляю коммит и пушу в репозиторий

![gitlab](img/16.png?raw=true "Title")

5. правлю код по рекомендации SONARQUBE

![gitlab](img/31.png?raw=true "Title")

```
<Center class="h-100" v-else></Center>
			заменил на
			<div class="h-100" style="text-align:center" v-else></div>
		<Center v-if="loading" class="mx-2"></Center>
			заменил на
			<div style="text-align:center" v-if="loading" class="mx-2"></div>
		<Center></Center>
			заменил на
			<div style="text-align:center"></div>
		<Center class="h-100"></Center>
		color: white;color: black;
			заменил на
			color: black;
		<script src="https://kit.fontawesome.com/a9ae183e88.js" crossorigin="anonymous"></script>
			удалил
		<table class="table table-hover align-middle">
			заменил на
			<table class="table table-hover align-middle" aria-label="bucket">
		<template> <li...></li></template>
			заменил на 
			<template> <ul><li...></li></ul></template>
		<i class="fas fa-shopping-cart"></i>
			заменил на
			<em class="fas fa-shopping-cart"></em>
		<img src="@/assets/logo.png" style="margin-right: 15px; height: 57px;"/>Пельменная №2</router-link>
			заменил на
			<img src="@/assets/logo.png" style="margin-right: 15px; height: 57px;" alt="Momo-store"/>Пельменная №2</router-link>
```

![gitlab](img/39.png?raw=true "Title")

6. деплой на ВМ через docker context

![gitlab](img/40.png?raw=true "Title")
