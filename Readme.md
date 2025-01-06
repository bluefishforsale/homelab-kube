# Kubernetes Dependency map

## Update / pull all helm charts

```bash
cd /Users/terrac/Projects/bluefishorsale/homelab-kube/
# add repos for all charts
grep repository charts/*/Chart.yaml | awk '{print $1, $NF}' | while read file repo ; do (dirname $file | sed -e 's/.*\///g' ; echo $repo) | xargs helm repo add ; done
# grab all the charts
ls -1d charts/* | xargs -n1 -I% helm dep update %

```

## Create prometheus CRDs
We do this because some charts depend on these CRDs being in palce early so they can create their monitoring.

```bash
# unpack kube-prometheus-stack
cd '/Users/terrac/Projects/bluefishorsale/homelab-kube/charts/kube-prometheus-stack/charts'
ls -1tr | tail -1 | xargs tar xf

cd /Users/terrac/Projects/bluefishorsale/homelab-kube/
ls -1 charts/kube-prometheus-stack/charts/kube-prometheus-stack/charts/crds/crds/crd-* | xargs -n1 kubectl create -f
```
<!-- 
## CNI (choose one)

### Flannel

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

```bash
cd /Users/terrac/Projects/bluefishorsale/homelab-kube/
helm upgrade --install -n kube-system flannel  -f charts/flannel/values.yaml charts/flannel
```

### Cillium

```bash
cd /Users/terrac/Projects/bluefishorsale/homelab-kube/
helm upgrade --install -n kube-system cilium -f charts/cilium/values.yaml charts/cilium
``` -->

## metallb

```bash
helm upgrade --install -n metallb-system --create-namespace metallb -f charts/metallb/values.yaml charts/metallb
```

## metrics server needed for horizontal-pod-autoscaling

```bash
helm install metrics-server -n kube-system  -f charts/metrics-server/values.yaml  charts/metrics-server
```

## ingress-nginx

```bash
helm upgrade --install -n nginx --create-namespace ingress-nginx -f charts/ingress-nginx/values.yaml charts/ingress-nginx
```

<!-- ## dns but after cilium

```bash
helm upgrade --install -n kube-system  coredns -f charts/coredns/values.yaml charts/coredns
``` -->

## local NFS server to copy from

```bash
kubectl create ns media
kubectl apply -f ocean-nfs-pvc.yaml
```

## ceph-external
### on the host w/ kubectl

```bash
git clone git@github.com:rook/rook.git
kubectl apply -f rook/deploy/examples/crds.yaml
kubectl apply -f rook/deploy/examples/common.yaml
```

# edit the namespace of these to rook-ceph

```bash
kubectl apply -f rook/deploy/examples/operator.yaml
kubectl apply -f rook/deploy/examples/common-external.yaml
```

# on PVE proxmox node metal

```bash
git clone https://github.com/rook/rook.git
python3 ./rook/deploy/examples/create-external-cluster-resources.py --ceph-conf /etc/ceph/ceph.conf --rbd-data-pool-name cephfs_data --cephfs-metadata-pool-name cephfs_metadata --cephfs-filesystem-name cephfs --namespace rook-ceph --format bash
```

## on the host w/ kubectl context
### <paste exported credentials from previous step>

```bash
bash ./rook/deploy/examples/import-external-cluster.sh
```

## edit the namespace of this to rook-ceph

```bash
kubectl apply -f rook/deploy/examples/cluster-external.yaml
helm upgrade --install -n rook-ceph --create-namespace ceph-filesystems -f charts/ceph-filesystems/values.yaml charts/ceph-filesystems
```

## install argo server

```bash
helm upgrade --install -n argocd --create-namespace argo-cd -f charts/argo-cd/values.yaml charts/argo-cd/
```

## argo app of apps

```bash
helm upgrade --install -n argocd --create-namespace argocd-applications -f charts/argocd-applications/values.yaml charts/argocd-applications
```

## as of now we still need to remove the nginx webhook validation

```bash
kubectl delete ValidatingWebhookConfiguration -n nginx ingress-nginx-admission
```

## getting passwords

## rook-ceph UI password

- username : admin

```bash
kubectl get  secret -n rook-ceph rook-ceph-dashboard-password  --template={{.data.password}} | base64 -d ; echo
```

## argo-cd password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## rook ceph-external uninstall

```bash
kubectl delete -f rook/deploy/examples/cluster-external.yaml
kubectl delete -f rook/deploy/examples/common-external.yaml
kubectl delete -f rook/deploy/examples/operator.yaml
kubectl delete -f rook/deploy/examples/common.yaml
kubectl delete -f rook/deploy/examples/crds.yaml
```
