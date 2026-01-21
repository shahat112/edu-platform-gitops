# Demo App for CI/CD Testing

Это минимальное приложение для демонстрации CI/CD процесса.

## Структура
.
├── .github/workflows/
│ └── deploy.yml # GitHub Actions workflow
├── demo-app.yaml # Kubernetes манифесты
└── README.md # Документация

text

## Развертывание

1. При пуше в main ветку автоматически запускается деплоймент
2. Приложение разворачивается в namespace `demo-app`
3. Доступно по адресу: `demo-app.edu.local`

## Команды для ручного тестирования

```bash
# Проверить состояние приложения
kubectl get pods -n demo-app
kubectl get svc -n demo-app
kubectl get ingress -n demo-app

# Посмотреть логи
kubectl logs -l app=demo-app -n demo-app

# Удалить приложение
kubectl delete -f demo-app.yaml
Переменные окружения для CI/CD
Нужно установить в GitHub Secrets:

KUBECONFIG - содержимое kubeconfig файла
