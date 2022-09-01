# Kubernetes Dependency map
## Start thigns in this order

### New helm bootstrap + argo way
```
# CRDs so we don't need two passes
ls -1 charts/kube-prometheus-stack/charts/kube-prometheus-stack/crds/crd-* | xargs -n1 kubectl apply -f

# cilium so things have a network
helm upgrade --install -n kube-system cilium -f charts/cilium/values.yaml charts/cilium

# dns but after cilium
helm upgrade --install -n kube-system  coredns -f charts/coredns/values.yaml charts/coredns

# local NFS server to copy from
kubectl create ns media
kubectl apply -f ocean-nfs-pvc.yaml

# ceph appset / cluster def / pvc's
helm upgrade --install -n rook-ceph --create-namespace rook-ceph -f charts/rook-ceph/values-proxmox.yaml charts/rook-ceph
helm upgrade --install -n rook-ceph --create-namespace ceph-cluster -f charts/rook-ceph-cluster/values-proxmox.yaml charts/rook-ceph-cluster
helm upgrade --install -n rook-ceph --create-namespace ceph-filesystems -f charts/ceph-filesystems/values-proxmox.yaml charts/ceph-filesystems

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
git clone git@github.com:rook/rook.git
git clone rook/rook.git
python3 ./deploy/examples/create-external-cluster-resources.py --upgrade
ceph auth list | less  # save output

# on the host w/ kubectl
git clone git@github.com:rook/rook.git
kubectl apply -f deploy/examples/crds.yaml
kubectl apply -f deploy/examples/common.yaml
kubectl apply -f deploy/examples/operator.yaml

# on the host w/ kubectl
export NAMESPACE=rook-ceph
export CSI_CEPHFS_NODE_SECRET=AQCuhAtjQq6qHxAAEjygU7H1SbYjtKz68YGz2g==
export CSI_CEPHFS_NODE_SECRET_NAME=rook-ceph-cephfs-node

export CSI_CEPHFS_PROVISIONER_SECRET=AQCuhAtjkcCGHhAAXlSWuLp9msHnT8e/9PrAMQ==
export CSI_CEPHFS_PROVISIONER_SECRET_NAME=client.csi-rbd-provisioner

export CSI_RBD_NODE_SECRET=AQCuhAtjGdS1HRAAN8VH3bcz+u0hWO9fh9m3Vg==
export CSI_RBD_NODE_SECRET_NAME=client.csi-rbd-node

export CSI_RBD_PROVISIONER_SECRET=AQCuhAtjkcCGHhAAXlSWuLp9msHnT8e/9PrAMQ==
export CSI_RBD_PROVISIONER_SECRET_NAME=client.csi-rbd-provisioner

export ROOK_EXTERNAL_USERNAME=client.healthchecker
export ROOK_EXTERNAL_USER_SECRET='AQCuhAtj0d3EHBAApNoly4hPPs26VnRXvV360g=='

export ROOK_EXTERNAL_CEPH_MON_DATA='node004=191.168.1.104:6789,node005=192.168.1.105:6789,node006=192.168.1.106:6789'
export ROOK_EXTERNAL_FSID=a24ac40b-a648-45e3-a4f9-aa359c22e42b
export RBD_POOL_NAME=rbd-pool

bash ./deploy/examples/import-external-cluster.sh
kubectl -n rook-ceph patch secret rook-ceph-mon --type=json -p='[{"op": "remove", "path": "/data/ceph-secret"}]'
kubectl -n rook-ceph patch secret rook-ceph-mon --type=json -p='[{"op": "remove", "path": "/data/ceph-username"}]'

kubectl apply -f /home/terrac/Projects/bluefishforsale/homelab-kube/charts/rook-ceph-cluster/templates/external-cluster.yaml
