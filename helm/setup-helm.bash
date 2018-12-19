#!/bin/bash
set -euo pipefail

# Checksum this
curl -L https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz | tar xzf -
mv linux-amd64/helm ~/.local/bin

# Set up a service account with access to everything
kubectl apply -f tiller-permissions.yaml

# Set up tiller & restrict access to it
helm init --upgrade --service-account tiller
kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'
kubectl --namespace=kube-system rollout -w deployment/tiller-deploy
