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
kubectl get  secret -n rook-ceph rook-ceph-dashboard-password  --template={{.data.password}} | base64 -D
```

## argo-cd password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

# Ceph replace Disk / OSD

- determine failed OSDs
- determine which hosts those OSDs are on
- get lsblk listing for those hosts to capture LVM name
- get yaml from OSD showing LVM name (match with lsblk out)
- match osd -> lvm -> /dev/sd?
- ceph cluster CR: remove the bad disks
- toolbox: `ceph osd out osd.N`  (for each bad OSD)
- toolbox: `ceph osd purge osd.N --yes-i-really-mean-it`
- do this slowly and let data re-position
- toolbox: `ceph osd tree` (wait for all bad OSDs to be down or missing)
- replace physical disk, or use teardown / zap script to reset lvm and disk partitions
- toolbox: `ceph auth del osd.N` (for each osd being replaced)
- cluster CR: add disks back
- kube: restart deployment:  ceph-operator, ceph-mgr
- toolbox: `watch -n 10 "ceph osd tree"`

# ceph benchmarking procedure
## list pools already createed
ceph osd pool ls
## create benchmark pool
ceph osd pool create benchmark 128 128
###  create benchmark file (and benchmark write speeds)
rados bench -p benchmark 300 write --no-cleanup
### sequential read
rados bench -p benchmark 300 seq


#########################
Total time run:       91.841
Total reads made:     15810
Read size:            4194304
Object size:          4194304
Bandwidth (MB/sec):   688.581
Average IOPS:         172
Stddev IOPS:          22.932
Max IOPS:             208
Min IOPS:             57
Average Latency(s):   0.0916575
Max latency(s):       3.29196
Min latency(s):       0.0180587


(11 GB, 10 GiB) copied, 5.49271 s, 2.0 GB/s
real	0m5.518s
user	0m0.004s
sys	0m5.311s

(91 GB, 84 GiB) copied, 213.552 s, 424 MB/s
real	3m35.394s
user	0m0.137s
sys	1m8.268s


fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/movies/random_read_write.fio --bs=4k --iodepth=256 --readwrite=randrw --rwmixread=80 -runtime=300 --numjobs=4 --time_based --group_reporting --name=iops-test-job   --size=500GB  --eta-newline=1 --runtime=300

fio --filename=/movies/random_read_write.fio --size=500GB --direct=1 --rw=randrw --bs=4k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1
