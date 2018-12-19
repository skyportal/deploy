#!/bin/bash
set -euo pipefail

helm dep up
helm upgrade --install --namespace=support --wait support .
