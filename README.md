# Дипломный проект - DevOps для эксплуатации и разработки: интенсивный
Данный проект разработан  в учебных целях ЯндексПрактикум.

Чеклист для проверки

    Код хранится в GitLab с использованием любого git-flow
    В проекте присутствует .gitlab-ci.yml, в котором описаны шаги сборки
    Артефакты сборки (бинарные файлы, docker-образы или др.) публикуются в систему хранения (Nexus или аналоги)
    Артефакты сборки версионируются
    Написаны Dockerfile'ы для сборки Docker-образов бэкенда и фронтенда
      
        Бэкенд: бинарный файл Go в Docker-образе
        Фронтенд: HTML-страница раздаётся с Nginx
    В GitLab CI описан шаг сборки и публикации артефактов
    В GitLab CI описан шаг тестирования
    В GitLab CI описан шаг деплоя
    Развёрнут Kubernetes-кластер в облаке
    Kubernetes-кластер описан в виде кода, и код хранится в репозитории GitLab
    Конфигурация всех необходимых ресурсов описана согласно IaC
    Состояние Terraform'а хранится в S3
    Картинки, которые использует сайт, или другие небинарные файлы, необходимые для работы, хранятся в S3
    Секреты не хранятся в открытом виде
    Написаны Kubernetes-манифесты для публикации приложения
    Написан Helm-чарт для публикации приложения
    Helm-чарты публикуются и версионируются в Nexus
    Приложение подключено к системам логирования и мониторинга
    Есть дашборд, в котором можно посмотреть логи и состояние приложения

Для данного проекта я использую 3 ветки:

 main - содержит только описание проекта и детализация его реализации
 
 kubernetes - код сборки приложения используя docker-compose
 
 infrastructure - код развертывания приложения используя HELM charts, Argo cd, monitoring


Описания:
1. как собрать и запустить бекенд и фронт локально

https://github.com/yndingo/CI-CD/tree/main/local%20start

2. локальный запуск докер

https://github.com/yndingo/CI-CD/tree/main/local%20docker

3. локальный запуск докер компоуз

https://github.com/yndingo/CI-CD/tree/main/local%20docker%20compose 

4. запуск докер компоуз на гитлаб и исправление ошибок найденных с помощью SONARQUBE

https://github.com/yndingo/CI-CD/tree/main/docker%20compose%20gitlab%20and%20fix%20errors

5. перенос картинок в bucket s3

https://github.com/yndingo/CI-CD/tree/main/Move%20IMG%20to%20S3%20(Yandex%20Object%20Storage)

6. Виртуальная Машина - развертывание на ПЛАТНЫХ ресурсах и доменное имя

https://github.com/yndingo/CI-CD/tree/main/VM

7. Kubernetes - развертывание на ПЛАТНЫХ ресурсах и доменное имя

https://github.com/yndingo/CI-CD/tree/main/kubernetes

9. HELM

https://github.com/yndingo/CI-CD/tree/main/HELM
   
11. Argo CD

https://github.com/yndingo/CI-CD/tree/main/Argo%20cd

13. Мониторинг - логирование, Локи

https://github.com/yndingo/CI-CD/tree/main/logging

15. Мониторинг - Метрики, Прометеус - исправление бекенда, для получения рабочей гистограммы задержки сигнала

https://github.com/yndingo/CI-CD/tree/main/monitoring



В репозитории используется переменные которые необходимо определить до начала развертывания.

DEV_HOST - адрес/имя хоста для развертывания приложения

DEV_USER - имя пользователя для авторизации на хосте

dockerconfigjson - json для доступа в container registry gitlab из под docker compose

dockerconfigjson_helm - json для доступа в container registry gitlab для helm чартов

kubeconfig 	- статический ключ для доступа и выкатки релизов на k8s (kubernetes)

NEXUS_REPO_URL - адрес репозитория нексус

NEXUS_REPO_USER - логин для авторизации в нексус

NEXUS_REPO_PASS - пароль для авторизации в нексус

SONARQUBE_URL - адрес платформы для анализа кода сонаркуб

SONAR_LOGIN_BACKEND - ключ для проекта бекенд в сонаркуб

SONAR_LOGIN_FRONTEND - ключ для проекта фронта в сонаркуб

SONAR_PROJECT_KEY_BACKEND - айди репозитория бекенд в сонаркуб

SONAR_PROJECT_KEY_FRONTEND - айди репозитория фронта в сонаркуб

SSH_KNOWN_HOSTS - записываются отпечатки всех серверов, которые вы посещаете и не позволяет сливать пароли и секретные ключи, если отпечаток не совпал. Нужен для авторизации на хосте для развертывания приложения

SSH_PRIVATE_KEY - ключ для подключения к хосту/Виртуальной машине




