for NS in \
    argocd flannel istio-system media metallb monitoring nfs nginx nvidia radarr rook-ceph cert-manager;
    do
        kubectl create ns ${NS}
    done
