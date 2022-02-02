#!/bin/bash
kubectl exec -n media $(kubectl get pods -n media -l app.kubernetes.io/instance=plex  --output=jsonpath={.items..metadata.name}) -c plex --  \
 du -hs /transcode
kubectl exec -n media $(kubectl get pods -n media -l app.kubernetes.io/instance=plex  --output=jsonpath={.items..metadata.name}) -c plex --  \
 find "/transcode" -type f | head -n20