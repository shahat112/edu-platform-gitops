#!/bin/bash
# Получение kubeconfig для кластера

CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "edu-cluster")

echo "📋 Получение kubeconfig для кластера: $CLUSTER_NAME"

# Получаем kubeconfig
yc managed-kubernetes cluster get-credentials $CLUSTER_NAME --external

# Проверяем доступ
echo "✅ Проверка доступа к кластеру..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "🎉 Kubeconfig получен и настроен!"
echo "Команды для проверки:"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"
