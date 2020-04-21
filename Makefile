.PHONY: setup
.DEFAULT: deploy

KUSTOMIZE=~/.local/bin/kustomize

setup:
	curl -sfLo $(KUSTOMIZE) https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64
	chmod u+x $(KUSTOMIZE)

deploy:
	./config-apply.sh
	kustomize build overlays/dockerhub | kubectl apply -f -
	kubectl rollout status --timeout=2m deployment/web
	kubectl get services -o wide
