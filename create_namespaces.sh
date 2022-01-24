for NS in \
    flannel gpu-operator httpbin istio-system k8sdash kube-dash \
    lidarr loki media metallb monitoring nfs nginx nvidia nzbget plex radarr \
    rook-ceph sonarr tautulli tdarr ubuntu ;
    do
        kubectl create ns ${NS}
    done
