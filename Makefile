.PHONY: setup
.DEFAULT: deploy

deploy:
	./config-apply.sh
	kubectl apply -k overlays/dockerhub
	kubectl rollout status --timeout=2m deployment/web
	kubectl get services -o wide
