HELM - продожение KUBERNETES
	https://momo.std-int-005-06.su

Общие шаги от KUBERNETES 1-19.
Далее 20 - Развертывание абсолютно такое же, только публикация не KUBERNETES. а HELM.

20.1 установим Helm
	
     20.1.1 curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    	20.1.2 chmod 700 get_helm.sh
    	20.1.3 ./get_helm.sh

![Helm](img/1.png?raw=true "Title")

20.2 надо удалить kubernetes сборку, если есть

20.3 У HELM по другому воспринимается переменная dockerconfigjson чем у KUBERNETES, надо дополнительно все шифровать в base64

![Helm](img/2.png?raw=true "Title")

20.4 В helm нельзя как в kubectl задать пространство имен по умолчанию
	kubectl config set-context --current --namespace=std-int-005-06-kuber-diplom-momo-store
В результате в команде ".gitlab-ci-HELM" при деплое использовать
	--namespace=std-int-005-06-kuber-diplom-momo-store

20.5 Изменяю в папке "HELM" файл ".gitlab-ci-HELM". Просто добавляю перенос строки или удаляю перенос строки (enter/delete) и пушу измения в гит. Это провоцирует сборку и деплой данной папки.

20.6 посмотреть список установленных релизов и время их жизни
	helm list

![Helm](img/7.png?raw=true "Title")

Для уничтожения HELM релиза используем
	helm uninstall momo-store


















