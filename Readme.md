# Kubernetes Dependency map
## Start thigns in this order

```
sh ./create_namespaces.sh
kubectl apply -n flannel -f kube-flannel.yml
kubectl apply -n kube-system -f coredns-1.8.yaml
helm install metrics-server -n kube-system  -f charts/metrics-server/values.yaml  charts/metrics-server
kubectl apply -f ocean-nfs-pvc.yaml

helm install -n metallb metallb -f charts/metallb/values.yaml charts/metallb
helm install -n nginx ingress-nginx charts/ingress-nginx/
```
# deleting the webhook is a workaround for a weird issue
# https://stackoverflow.com/questions/61616203/nginx-ingress-controller-failed-calling-webhook
```
 kubectl delete ValidatingWebhookConfiguration -n nginx ingress-nginx-admission

 helm install -n rook-ceph rook-ceph -f charts/rook-ceph/values.yaml charts/rook-ceph
 helm install -n rook-ceph rook-ceph-cluster -f charts/rook-ceph-cluster/values.yaml charts/rook-ceph-cluster
 helm install -n rook-ceph ceph-filesystems -f charts/ceph-filesystems/values.yaml charts/ceph-filesystems

 helm install -n monitoring prom -f charts/kube-prometheus-stack/values.yaml charts/kube-prometheus-stack
 helm install -n monitoring loki -f charts/loki/values.yaml charts/loki
 helm install -n monitoring promtail -f charts/promtail/values.yaml charts/promtail

 helm install -n media rsyc-cron -f charts/rsync-cron/values.yaml  charts/rsync-cron

 helm install nvidia-device-plugin -f charts/nvidia-device-plugin/values.yaml charts/nvidia-device-plugin
 helm install -n media plex -f charts/plex/values.yaml charts/plex
 helm install -n media tautulli -f charts/tautulli/values.yaml charts/tautulli
 helm install -n media sonarr -f charts/sonarr/values.yaml charts/sonarr
 helm install -n media radarr -f charts/radarr/values.yaml charts/radarr
 helm install -n media nzbget -f charts/nzbget/values.yaml charts/nzbget
```

# how to get rook-ceph password
* username : admin
```
kubectl get  secret -n rook-ceph rook-ceph-dashboard-password  --template={{.data.password}} | base64 -D
```