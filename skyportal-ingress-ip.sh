kubectl get ingress skyportal-ingress \
    -o jsonpath='{.status.loadBalancer.ingress[].ip}{"\n"}'
