#!/bin/bash
kubectl exec -n media $(kubectl get pods -n media -l app.kubernetes.io/instance=plex  --output=jsonpath={.items..metadata.name}) -c plex -- ls -l "/config/Library/Application Support/Plex Media Server/Logs"