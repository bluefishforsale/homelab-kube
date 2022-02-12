# Kubernetes Dependency map
## Start thigns in this order

1. sh ./create_namespaces.sh
1. kubectl apply -n flannel -f kube-flannel.yml
1. kubectl apply -n kube-system -f coredns-1.8.yaml
1. helm install metrics-server -n kube-system  -f charts/metrics-server/values.yaml  charts/metrics-server
1. kubectl apply -f ocean-nfs-pvc.yaml

1. helm install -n metallb metallb -f charts/metallb/values.yaml charts/metallb
1. helm install -n nginx ingress-nginx charts/ingress-nginx/
# deleting the webhook is a workaround for a weird issue
# https://stackoverflow.com/questions/61616203/nginx-ingress-controller-failed-calling-webhook
1. kubectl delete ValidatingWebhookConfiguration -n nginx ingress-nginx-admission

1. helm install -n rook-ceph rook-ceph -f charts/rook-ceph/values.yaml charts/rook-ceph
1. helm install -n rook-ceph rook-ceph-cluster -f charts/rook-ceph-cluster/values.yaml charts/rook-ceph-cluster
1. helm install -n rook-ceph ceph-filesystems -f charts/ceph-filesystems/values.yaml charts/ceph-filesystems

1. helm install -n monitoring prom -f charts/kube-prometheus-stack/values.yaml charts/kube-prometheus-stack
1. helm install -n monitoring promtail -f charts/promtail/values.yaml charts/promtail
1. helm install -n monitoring loki -f charts/loki/values.yaml charts/loki

1. helm install nvidia-device-plugin -f charts/nvidia-device-plugin/values.yaml charts/nvidia-device-plugin
1. helm install -n media -f plex charts/plex/values.yaml charts/plex
1. helm install -n media sonarr -f charts/sonarr/values.yaml charts/sonarr
1. helm install -n media radarr -f charts/radarr/values.yaml charts/radarr
1. helm install -n media -f tautulli charts/tautulli/values.yaml charts/tautulli
1. helm install -n media nzbget -f charts/nzbget/values.yaml charts/nzbget

# how to get rook-ceph password
* username : admin
```
kubectl get  secret -n rook-ceph rook-ceph-dashboard-password  --template={{.data.password}} | base64 -D
```