# Kubernetes Dependency map
## Start thigns in this order

1. sh ./create_namespaces.sh
1. kubectl apply -n flannel -f kube-flannel.yml
1. kubectl apply -n kube-system -f coredns-1.8.yaml
1. kubectl apply -f ocean-nfs-pvc.yaml
1. helm install -n rook-ceph rook-ceph -f charts/rook-ceph/values.yaml charts/rook-ceph
1. helm install -n rook-ceph rook-ceph-cluster -f charts/rook-ceph-cluster/values.yaml charts/rook-ceph-cluster/
1. helm install -n rook-ceph ceph-filesystems charts/ceph-filesystems
1. helm install metallb -n metallb -f charts/metallb/values.yaml charts/metallb
1. helm install  -n nginx ingress-nginx charts/ingress-nginx/
1. helm install -n monitoring prom -f charts/kube-prometheus-stack/values.yaml charts/kube-prometheus-stack
1. helm install promtail -n monitoring -f charts/promtail/values.yaml charts/promtail
1. helm install loki -n monitoring -f charts/loki/values.yaml charts/loki
1. helm install  sonarr -n media -f charts/sonarr/values.yaml charts/sonarr
1. helm install radarr -n media -f charts/radarr/values.yaml charts/radarr
1. helm install plex -n media -f charts/plex/values.yaml charts/plex
1. helm install nzbget -n media  -f charts/nzbget/values.yaml charts/nzbget