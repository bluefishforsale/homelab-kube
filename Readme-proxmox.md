# Kubernetes Dependency map
## Start thigns in this order

### New helm bootstrap + argo way
```

# first time in repo, update / pull all helm charts
ls -1d  update charts/* | xargs -n1 -I% helm dep update %
cd '/Users/terrac/Projects/bluefishforsale/homelab-kube/charts/kube-prometheus-stack/charts'
tar xf kube-prometheus-stack-36.0.1.tgz

# CRDs so we don't need two passes
ls -1 charts/kube-prometheus-stack/charts/kube-prometheus-stack/crds/crd-* | xargs -n1 kubectl apply -f

# cilium so things have a network
helm upgrade --install -n kube-system cilium -f charts/cilium/values.yaml charts/cilium

# dns but after cilium
helm upgrade --install -n kube-system  coredns -f charts/coredns/values.yaml charts/coredns

# local NFS server to copy from
kubectl create ns media
kubectl apply -f ocean-nfs-pvc.yaml

<!--
# ceph appset / cluster def / pvc's
helm upgrade --install -n rook-ceph --create-namespace rook-ceph -f charts/rook-ceph/values-proxmox.yaml charts/rook-ceph
helm upgrade --install -n rook-ceph --create-namespace ceph-cluster -f charts/rook-ceph-cluster/values-proxmox.yaml charts/rook-ceph-cluster
helm upgrade --install -n rook-ceph --create-namespace ceph-filesystems -f charts/ceph-filesystems/values-proxmox.yaml charts/ceph-filesystems
 -->

# install argo server
helm upgrade --install -n argocd --create-namespace argo-cd -f charts/argo-cd/values.yaml charts/argo-cd/

# argo app of apps
helm upgrade --install -n argocd --create-namespace argocd-applications -f charts/argocd-applications/values.yaml charts/argocd-applications
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

# on ceph host
git clone https://github.com/rook/rook.git
cd rook/
python3 ./deploy/examples/create-external-cluster-resources.py --ceph-conf /etc/ceph/ceph.conf --rbd-data-pool-name cephfs_data --cephfs-metadata-pool-name cephfs_metadata --cephfs-filesystem-name cephfs --namespace rook-ceph --format bash --dry-run

python3 ./deploy/examples/create-external-cluster-resources.py --upgrade
ceph auth list | less  # save output

# on the host w/ kubectl
git clone git@github.com:rook/rook.git
kubectl apply -f deploy/examples/crds.yaml
kubectl apply -f deploy/examples/common.yaml
# edit the namespace of these to rook-ceph
kubectl apply -f deploy/examples/operator.yaml
kubectl apply -f deploy/examples/common-external.yaml

# on the host w/ kubectl context
<paste export credentials>
bash ./deploy/examples/import-external-cluster.sh

# edit the namespace of this to rook-ceph
kubectl apply -f deploy/examples/cluster-external.yaml


kubectl -n rook-ceph patch secret rook-ceph-mon --type=json -p='[{"op": "remove", "path": "/data/ceph-secret"}]'
kubectl -n rook-ceph patch secret rook-ceph-mon --type=json -p='[{"op": "remove", "path": "/data/ceph-username"}]'

kubectl apply -f /home/terrac/Projects/bluefishforsale/homelab-kube/charts/rook-ceph-cluster/templates/external-cluster.yaml

kubectl delete -f deploy/examples/cluster-external.yaml
kubectl delete -f deploy/examples/common-external.yaml
kubectl delete -f deploy/examples/operator.yaml
kubectl delete -f deploy/examples/common.yaml
kubectl delete -f deploy/examples/crds.yaml

