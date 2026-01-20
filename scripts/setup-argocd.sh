#!/bin/bash
# Скрипт установки ArgoCD и настройки GitOps

set -e

echo "🚀 Установка ArgoCD для GitOps..."

# 1. Создаем namespace для ArgoCD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# 2. Устанавливаем ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Ждем готовности pods
echo "⏳ Ожидаем запуска ArgoCD..."
sleep 30
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# 4. Получаем пароль администратора
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "🔑 ArgoCD Admin Password: $ARGOCD_PASSWORD"

# 5. Создаем namespace для приложений
kubectl create namespace edu-platform --dry-run=client -o yaml | kubectl apply -f -

# 6. Применяем манифесты ArgoCD
kubectl apply -f manifests/argocd/

echo ""
echo "✅ ArgoCD установлен!"
echo "🌐 Доступ к UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "🔑 Логин: admin"
echo "🔑 Пароль: $ARGOCD_PASSWORD"
