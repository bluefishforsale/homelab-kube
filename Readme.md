# Kubernetes Dependency map
## Start thigns in this order

### New helm bootstrap + argo way
```
# CRDs so we don't need two passes
kubectl apply  -f charts/kube-prometheus-stack/charts/kube-prometheus-stack/crds/crd-*

# cilium so things have a network
helm upgrade --install -n kube-system cilium -f charts/cilium/values.yaml charts/cilium

# dns but after cilium
helm upgrade --install -n kube-system  coredns -f charts/coredns/values.yaml charts/coredns

# local NFS server to copy from
kubectl create ns media
kubectl apply -f ocean-nfs-pvc.yaml

# ceph appset / cluster def / pvc's
helm upgrade --install -n rook-ceph --create-namespace rook-cephargocd-applications -f charts/rook-ceph/values.yaml charts/rook-ceph
helm upgrade --install -n rook-ceph --create-namespace rook-ceph-cluster -f charts/rook-ceph-cluster/values.yaml charts/rook-ceph-cluster
helm upgrade --install -n rook-ceph --create-namespace ceph-filesystems -f charts/ceph-filesystems/values.yaml charts/ceph-filesystems

# install argo server
helm upgrade --install -n argocd --create-namespace argo-cd -f charts/argo-cd/values.yaml charts/argo-cd/

# argo app of apps
helm upgrade --install -n argocd --create-namespace argocd-applications -f charts/argocd-applications/values.yaml charts/argocd-applications

```

### OLD MANUAL HELM WAY
```
sh ./create_namespaces.sh
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

 helm upgrade --install -n rook-ceph rook-ceph -f charts/rook-ceph/values.yaml charts/rook-ceph
 helm upgrade --install -n rook-ceph rook-ceph-cluster -f charts/rook-ceph-cluster/values.yaml charts/rook-ceph-cluster
 helm upgrade --install -n rook-ceph ceph-filesystems -f charts/ceph-filesystems/values.yaml charts/ceph-filesystems

 helm upgrade --install -n monitoring prom -f charts/kube-prometheus-stack/values.yaml charts/kube-prometheus-stack
 helm upgrade --install -n monitoring loki -f charts/loki/values.yaml charts/loki
 helm upgrade --install -n monitoring promtail -f charts/promtail/values.yaml charts/promtail

 helm upgrade --install -n cert-manager cert-manager -f charts/cert-manager/values.yaml charts/cert-manager
 helm upgrade --install -n argo-cd argo-cd -f charts/argo-cd/values.yaml charts/argo-cd/


 helm upgrade --install -n media rsyc-cron -f charts/rsync-cron/values.yaml  charts/rsync-cron

 helm upgrade --install nvidia-device-plugin -f charts/nvidia-device-plugin/values.yaml charts/nvidia-device-plugin
 helm upgrade --install -n media plex -f charts/plex/values.yaml charts/plex
 helm upgrade --install -n media tautulli -f charts/tautulli/values.yaml charts/tautulli
 helm upgrade --install -n media sonarr -f charts/sonarr/values.yaml charts/sonarr
 helm upgrade --install -n media radarr -f charts/radarr/values.yaml charts/radarr
 helm upgrade --install -n media nzbget -f charts/nzbget/values.yaml charts/nzbget
```

# getting passwords
## rook-ceph UI password
* username : admin
```
kubectl get  secret -n rook-ceph rook-ceph-dashboard-password  --template={{.data.password}} | base64 -d ; echo
```

## argo-cd password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
