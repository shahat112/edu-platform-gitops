#!/bin/bash

# Скрипт настройки GitOps пайплайна
set -e

echo "🚀 Настройка GitOps CI/CD пайплайна для учебной платформы"

# 1. Установка ArgoCD
echo "📦 Устанавливаем ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Получение пароля ArgoCD
echo "🔑 Получаем пароль ArgoCD..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD password: $ARGOCD_PASSWORD"

# 3. Создание namespace для приложения
echo "🏗️ Создаем namespace edu-platform..."
kubectl create namespace edu-platform --dry-run=client -o yaml | kubectl apply -f -

# 4. Создание секретов (замените значениями из Yandex Cloud)
echo "🔐 Создаем секреты..."
kubectl create secret generic postgres-secret \
  --namespace edu-platform \
  --from-literal=username=admin \
  --from-literal=password=$(openssl rand -base64 32) \
  --from-literal=url=postgresql://postgresql.edu-platform.svc.cluster.local:5432/edu_platform \
  --dry-run=client -o yaml | kubectl apply -f -

# 5. Применение манифестов ArgoCD
echo "🔄 Применяем ArgoCD ApplicationSet..."
kubectl apply -f manifests/argocd/

# 6. Порт-форвардинг для доступа к ArgoCD UI
echo "🌐 Запускаем порт-форвардинг ArgoCD..."
echo "ArgoCD UI будет доступен по адресу: http://localhost:8080"
echo "Логин: admin"
echo "Пароль: $ARGOCD_PASSWORD"
echo "Для остановки нажмите Ctrl+C"

kubectl port-forward svc/argocd-server -n argocd 8080:443

echo "✅ Настройка завершена!"
