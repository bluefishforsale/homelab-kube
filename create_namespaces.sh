for NS in \
    flannel istio-system media metallb monitoring nfs nginx nvidia radarr rook-ceph ;
    do
        kubectl create ns ${NS}
    done
