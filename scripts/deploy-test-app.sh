#!/bin/bash
set -e

echo "🚀 Deploying Load Balancer Test Application..."

# Проверяем доступность kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install and configure kubectl"
    exit 1
fi

# Проверяем подключение к кластеру
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

# Деплой тестового приложения
echo "📦 Applying test application manifests..."
kubectl apply -f apps/tests/loadbalancer.yaml

# Ждем запуска подов
echo "⏳ Waiting for pods to be ready..."
sleep 10

# Проверяем статус
echo "📊 Checking deployment status..."
kubectl get pods -n edu-platform-test -o wide
kubectl get svc -n edu-platform-test
kubectl get deployment -n edu-platform-test

# Получаем IP Load Balancer из Terraform (если есть)
if command -v terraform &> /dev/null && [ -f "../../terraform.tfstate" ]; then
    echo "🌐 Load Balancer information from Terraform:"
    terraform output lb_ip 2>/dev/null || echo "Load Balancer IP not available yet"
fi

echo ""
echo "✅ Test application deployed successfully!"
echo ""
echo "🔧 Test commands:"
echo "   kubectl port-forward svc/loadbalancer-test-service 8080:80 -n edu-platform-test"
echo "   curl http://localhost:8080/health"
echo "   kubectl logs -l app=loadbalancer-test -n edu-platform-test --tail=10"
