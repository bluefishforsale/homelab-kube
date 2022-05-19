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

 helm install -n cert-manager cert-manager -f charts/cert-manager/values.yaml charts/cert-manager

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
