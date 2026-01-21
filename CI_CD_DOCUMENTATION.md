# 📚 ДОКУМЕНТАЦИЯ ПО CI/CD ПАЙПЛАЙНУ

## 🎯 ОБЗОР АРХИТЕКТУРЫ
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Developer │ │ GitHub Repo │ │ GitHub Actions │
│ Code │───▶│ Main Branch │───▶│ CI/CD Pipe │
└─────────────────┘ └─────────────────┘ └─────────────────┘
│
▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Kubernetes │◀───│ Yandex Cloud │◀───│ Docker Images │
│ Cluster │ │ Container Reg │ │ Built & Tagged│
└─────────────────┘ └─────────────────┘ └─────────────────┘
│
▼
┌─────────────────┐
│ Users │
│ Access Apps │
└─────────────────┘

text

## 🔧 КОМПОНЕНТЫ СИСТЕМЫ

### 1. Исходный код
- **Репозиторий:** https://github.com/shahat112/edu-platform-gitops
- **Структура:**
/apps/ # Приложения
/frontend/ # React приложение
/backend/ # Node.js API
/api/ # Python FastAPI
/kubernetes/ # Манифесты Kubernetes
/manifests/ # ArgoCD конфигурации
/.github/workflows/ # CI/CD пайплайны

text

### 2. CI/CD Pipeline (.github/workflows/full-ci-cd.yaml)
**Этапы выполнения:**

1. **test** (при Pull Request):
 - Линтинг кода
 - Юнит-тесты
 - Проверка качества

2. **build-and-push** (при пуше в main):
 - Сборка Docker образов
 - Тегирование (latest + git SHA)
 - Загрузка в Yandex Container Registry

3. **deploy** (автоматический деплой):
 - Настройка kubectl
 - Применение манифестов Kubernetes
 - Rolling update приложений
 - Проверка health checks

4. **post-deploy** (уведомления):
 - Статус деплоя
 - Уведомления в Slack/Telegram

### 3. Инфраструктура как код
- **Terraform:** main.tf (Yandex Cloud ресурсы)
- **Kubernetes Manifests:** apps/*/manifests/
- **ArgoCD:** manifests/argocd/

### 4. Мониторинг и логи
- **Kubernetes:** kubectl logs, describe
- **Health Checks:** readiness/liveness probes
- **ArgoCD:** Визуализация состояния

## 🚀 БЫСТРЫЙ СТАРТ

### 1. Клонирование и настройка
```bash
git clone https://github.com/shahat112/edu-platform-gitops
cd edu-platform-gitops
2. Настройка секретов в GitHub
Перейдите в Settings → Secrets and variables → Actions

Добавьте секреты:

KUBECONFIG (base64 encoded kubeconfig)

YC_SERVICE_ACCOUNT_KEY (содержимое key.json)

3. Запуск пайплайна
bash
git add .
git commit -m "Обновление приложения"
git push origin main
4. Мониторинг выполнения
GitHub → Actions → CI/CD Pipeline

Kubernetes: kubectl get pods -n edu-platform --watch

ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443

🛠 УПРАВЛЕНИЕ ПРИЛОЖЕНИЯМИ
Масштабирование
bash
# Увеличить количество реплик
kubectl scale deployment frontend-app --replicas=5 -n edu-platform

# Автоскейлинг
kubectl autoscale deployment frontend-app --min=2 --max=10 --cpu-percent=80 -n edu-platform
Обновление
bash
# Ручное обновление образа
kubectl set image deployment/frontend-app frontend=cr.yandex/your-registry/frontend:v2.0 -n edu-platform

# Откат
kubectl rollout undo deployment/frontend-app -n edu-platform
Мониторинг
bash
# Логи приложения
kubectl logs deployment/frontend-app -n edu-platform --tail=50

# Статус деплоя
kubectl rollout status deployment/frontend-app -n edu-platform

# Метрики ресурсов
kubectl top pods -n edu-platform
🔍 УСТРАНЕНИЕ НЕИСПРАВНОСТЕЙ
Проблемы с образами
bash
# Проверить события пода
kubectl describe pod <pod-name> -n edu-platform

# Проверить логи
kubectl logs <pod-name> -n edu-platform --previous
Проблемы с сетью
bash
# Проверить сервисы
kubectl describe svc frontend-app -n edu-platform

# Проверить ingress
kubectl describe ingress edu-platform-ingress -n edu-platform
Проблемы с CI/CD
Проверить секреты в GitHub

Проверить права Service Account

Проверить доступность Container Registry

📈 BEST PRACTICES
Версионирование: Всегда используйте теги для Docker образов

Здоровье приложений: Настройте readiness/liveness probes

Безопасность: Используйте secrets для конфиденциальных данных

Мониторинг: Настройте алертинг для critical событий

Резервное копирование: Регулярно бэкапите БД и конфигурации

🎓 ЧЕМУ УЧИТ ЭТОТ ПРОЕКТ
Modern DevOps: Полный цикл CI/CD

Cloud Native: Контейнеры, оркестрация, облако

Infrastructure as Code: Управление через код

GitOps: Декларативное управление конфигурацией

Микросервисы: Разделение ответственности

🔗 ПОЛЕЗНЫЕ ССЫЛКИ
Kubernetes Documentation

GitHub Actions

ArgoCD Documentation

Yandex Cloud

Terraform
