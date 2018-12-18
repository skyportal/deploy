sops --decrypt config-secret.enc.yaml | kubectl apply -f -
