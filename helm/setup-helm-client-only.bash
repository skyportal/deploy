#!/bin/bash
set -euo pipefail

# Checksum this
curl -L https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz | tar xzf -
mv linux-amd64/helm ~/.local/bin

# Set up tiller & restrict access to it
helm init --client-only
