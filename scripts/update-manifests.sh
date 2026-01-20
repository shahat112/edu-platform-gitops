#!/bin/bash
# Обновление манифестов Kubernetes с реальными endpoint'ами из Terraform

echo "🔄 Обновление манифестов с реальными данными..."

# Получаем outputs из Terraform
POSTGRES_ENDPOINT=$(terraform output -raw postgres_endpoint)
CLICKHOUSE_ENDPOINT=$(terraform output -raw clickhouse_endpoint)
REDIS_ENDPOINT=$(terraform output -raw redis_endpoint)
REGISTRY_ID=$(terraform output -raw registry_id)

# Обновляем манифесты API
cat << YAML > manifests/apps/api/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
  namespace: edu-platform
data:
  DATABASE_URL: "postgresql://${POSTGRES_ENDPOINT}:6432/edu_platform"
  REDIS_URL: "redis://${REDIS_ENDPOINT}:6379"
  CLICKHOUSE_HOST: "${CLICKHOUSE_ENDPOINT}"
  CLICKHOUSE_PORT: "9440"
YAML

# Обновляем deployment с реальным registry
sed -i "s|<registry-id>|${REGISTRY_ID}|g" manifests/apps/api/deployment.yaml
sed -i "s|<registry-id>|${REGISTRY_ID}|g" manifests/apps/frontend/deployment.yaml

echo "✅ Манифесты обновлены!"
echo "   PostgreSQL: ${POSTGRES_ENDPOINT}"
echo "   ClickHouse: ${CLICKHOUSE_ENDPOINT}"
echo "   Redis: ${REDIS_ENDPOINT}"
echo "   Registry: ${REGISTRY_ID}"
