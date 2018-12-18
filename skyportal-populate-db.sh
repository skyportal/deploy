#!/bin/bash

FIRST_POD=$(kubectl get pods \
                    -l app=frontend \
                    -o jsonpath='{.items[0].metadata.name}{"\n"}')
CONTAINER=web

kubectl exec --container=$CONTAINER $FIRST_POD -- bash -c \
        'source /skyportal_env/bin/activate && \
         PYTHONPATH=. python skyportal/model_util.py'
