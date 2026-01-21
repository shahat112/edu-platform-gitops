# Minimal CI/CD Demo for Educational Platform

## Overview
This is a minimal CI/CD demonstration using GitHub Actions. It shows the basic workflow pattern for deploying applications to Kubernetes.

## What's Included

### 1. Minimal Application (`minimal-demo.yaml`)
- ConfigMap with application settings
- Deployment with 1 replica
- Service (ClusterIP)
- Uses nginx:alpine as base image
- Resource limits defined
- Environment variables from ConfigMap

### 2. CI/CD Pipeline (`.github/workflows/minimal-ci-demo.yaml`)
- **show-info**: Displays repository information
- **validate**: Checks Kubernetes manifest structure
- **simulate-deploy**: Simulates deployment process
- **summary**: Provides workflow summary

## How It Works

### Pipeline Triggers
1. **Push to main branch**: Runs full pipeline
2. **Pull Request**: Runs validation only
3. **Manual trigger**: Can be started from GitHub UI

### Pipeline Stages
Push Event → Show Info → Validate → Simulate Deploy → Summary

text

## Running the Demo

### 1. View the Workflow
- Go to GitHub repository → Actions tab
- Click on "Minimal CI/CD Demo"
- View the workflow runs

### 2. Trigger Manually
- Go to Actions tab
- Select "Minimal CI/CD Demo"
- Click "Run workflow"
- Select branch (main) and run

### 3. Check Results
Each job shows:
- ✅ Success or ❌ Failure
- Console output from each step
- Execution time
- Artifacts (if any)

## For Real Deployment

To convert this to real deployment:

1. **Add GitHub Secrets**:
   ```bash
   # Encode kubeconfig
   cat kubeconfig.yaml | base64 -w0
Add as secret: KUBECONFIG

Update workflow:

Replace simulation with actual kubectl commands

Add rollback logic

Implement health checks

Add features:

Notifications (Slack, Email)

Automated testing

Security scanning

Performance testing

File Structure
text
.github/workflows/
└── minimal-ci-demo.yaml    # CI/CD pipeline definition
minimal-demo.yaml           # Kubernetes application
README-CI-DEMO.md          # This documentation
Learning Points
This demo shows:

✅ Multi-stage CI/CD pipeline

✅ Conditional execution (PR vs push)

✅ Job dependencies (needs: parameter)

✅ Simulation vs production workflow

✅ Basic Kubernetes manifest validation

Next Steps
Enhance validation:

Add kubeval for schema validation

Add conftest for policy checking

Add trivy for security scanning

Add deployment stages:

Development environment

Staging environment

Production environment (with approvals)

Monitoring:

Add deployment metrics

Link to Grafana dashboards

Error tracking integration

Cleanup
To remove this demo:

bash
rm minimal-demo.yaml .github/workflows/minimal-ci-demo.yaml README-CI-DEMO.md
Support
This is a minimal educational demo. For production use, consider:

Using established CI/CD tools

Implementing proper security practices

Adding comprehensive testing

Setting up monitoring and alerting
