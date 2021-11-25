for NS in \
    flannel httpbin istio-system k8sdash kube-dash lidarr loki metallb rook-ceph \
    monitoring nfs nginx nzbget plex radarr sonarr tautulli tdarr ubuntu ;
    do
        kubectl create ns ${NS}
    done
