GitLab для хранения кода, организации процесса сборки и доставки, хранения артефактов;

		https://gitlab.praktikum-services.ru/

Nexus для хранения артефактов сборки;

		https://nexus.praktikum-services.tech/

SonarQube для анализа кода.

		https://sonarqube.praktikum-services.ru/

1. Создал проект гитлаб
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
	
данные которые завести в гитлаб для подключения

  		NEXUS_REPO_URL = https://nexus.praktikum-services.tech
  		NEXUS_REPO_USER = std-int-005-006
  		NEXUS_REPO_PASS = 

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

7. правлю код по рекомендации SONARQUBE

                              











































