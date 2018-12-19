#!/bin/bash
set -euo pipefail

helm dep up
helm upgrade --install --namespace=support --timeout=60 support .
