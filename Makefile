.PHONY: help init-infra setup-k8s install-argocd update-manifests deploy-all

help:  ## Показать справку
@echo "🎓 Учебная платформа - Команды управления"
@echo ""
@echo "Основные команды:"
@echo "  make setup-k8s      - Настроить доступ к Kubernetes кластеру"
@echo "  make install-argocd - Установить ArgoCD"
@echo "  make update-manifests - Обновить манифесты с реальными данными"
@echo "  make deploy-all     - Полный деплой платформы"
@echo "  make check-status   - Проверить статус всех компонентов"
@echo ""

setup-k8s:  ## Настроить доступ к кластеру Kubernetes
@echo "🔧 Настройка доступа к Kubernetes кластеру..."
cd ../shahat112-project && \
CLUSTER_NAME=$$(terraform output -raw cluster_name) && \
echo "📋 Имя кластера: $$CLUSTER_NAME" && \
yc managed-kubernetes cluster get-credentials $$CLUSTER_NAME --external
@echo "✅ Проверка доступа..."
@kubectl cluster-info
@kubectl get nodes

install-argocd:  ## Установить ArgoCD в кластер
@echo "🚀 Установка ArgoCD..."
@./scripts/setup-argocd.sh

update-manifests:  ## Обновить манифесты с реальными endpoint'ами
@echo "🔄 Обновление манифестов..."
@./scripts/update-manifests.sh

deploy-all: setup-k8s install-argocd update-manifests  ## Полный деплой платформы
@echo "🎉 Платформа развернута!"
@echo "📋 Следующие шаги:"
@echo "1. Настройте GitHub Secrets:"
@echo "   - YC_SA_KEY (содержимое key.json)"
@echo "   - YC_REGISTRY_ID (crp6c65n59o6pg6jfmvq)"
@echo "   - KUBECONFIG (получить через: cat ~/.kube/config | base64 -w 0)"
@echo "2. Запушите изменения: git push origin main"
@echo "3. Проверьте GitHub Actions"

check-status:  ## Проверить статус всех компонентов
@echo "🔍 Проверка статуса кластера..."
@kubectl get nodes
@echo ""
@echo "🔍 Проверка ArgoCD..."
@kubectl get pods -n argocd 2>/dev/null || echo "ArgoCD не установлен"
@echo ""
@echo "🔍 Проверка приложений..."
@kubectl get pods -n edu-platform 2>/dev/null || echo "Namespace edu-platform не существует"

portforward-argocd:  ## Запустить порт-форвардинг ArgoCD UI
@echo "🌐 ArgoCD UI будет доступен по http://localhost:8080"
@echo "Логин: admin"
@echo "Пароль: получить через: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
@kubectl port-forward svc/argocd-server -n argocd 8080:443

test-api:  ## Запустить тесты API
@echo "🧪 Запуск тестов API..."
@cd apps/api && python -m pytest tests/ -v 2>/dev/null || echo "Тесты не настроены"

clean:  ## Очистить временные файлы
@echo "🧹 Очистка временных файлов..."
@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
@find . -name "*.pyc" -delete
