#!/bin/bash

FIRST_POD=$(kubectl get pods -l app=skyportal-web | tail -n 1 | cut -f 1 -d ' ')
CONTAINER=web

kubectl exec --container=$CONTAINER $FIRST_POD -- bash -c 'source /skyportal_env/bin/activate && PYTHONPATH=. python skyportal/model_util.py'
