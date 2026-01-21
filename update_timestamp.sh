#!/bin/bash
# Скрипт для обновления timestamp в health endpoint

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "s/REPLACE_TIMESTAMP/$TIMESTAMP/g" html/health.html
echo "Updated timestamp to: $TIMESTAMP"
