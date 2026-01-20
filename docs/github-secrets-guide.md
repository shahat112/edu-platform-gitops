# 🔐 Настройка GitHub Secrets для CI/CD

После успешного выполнения `terraform apply` нужно настроить следующие секреты в GitHub:

## 1. Получение данных из Terraform

```bash
cd ~/shahat112-project
terraform output

# Сохраните эти значения:
# - cluster_name
# - registry_id
# - postgres_endpoint
# - clickhouse_endpoint
# - redis_endpoint
2. GitHub Secrets (Settings → Secrets and variables → Actions)
Обязательные секреты:
Secret NameDescriptionКак получить
YC_SA_KEYКлюч сервисного аккаунтаСодержимое файла key.json
YC_REGISTRY_IDID Container Registryterraform output -raw registry_id
YC_FOLDER_IDID каталога Yandex Cloudb1gqbh9n63qaria5u2tj
KUBECONFIGКонфиг KubernetesВыполнить: yc managed-kubernetes cluster get-credentials <cluster_name> --external --silent
Дополнительные (опционально):
Secret NameDescription
ARGOCD_PASSWORDПароль ArgoCD (после установки)
SLACK_WEBHOOKДля уведомлений в Slack
DOCKERHUB_TOKENЕсли используете Docker Hub
3. Получение KUBECONFIG
bash
# После terraform apply получите имя кластера
CLUSTER_NAME=$(terraform output -raw cluster_name)

# Получите kubeconfig
yc managed-kubernetes cluster get-credentials $CLUSTER_NAME --external --silent

# Скопируйте содержимое ~/.kube/config
cat ~/.kube/config
4. Проверка доступов
После настройки секретов, workflow должен успешно:

Авторизовываться в Yandex Container Registry

Собирать и пушить Docker образы

Развертывать приложения через ArgoCD

5. Troubleshooting
Если возникают ошибки аутентификации:

Проверьте срок действия ключа в key.json

Убедитесь, что сервисный аккаунт имеет необходимые роли

Проверьте формат KUBECONFIG (должен быть в одну строку с экранированными переводами строк)
