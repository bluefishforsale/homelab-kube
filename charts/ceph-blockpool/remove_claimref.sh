kubectl get pv -n media | awk '(!/NAME/){print $1}' | xargs -n1 -J{} kubectl patch pv {} -p '{"spec":{"claimRef": null}}'

kubectl get pvc -n media | awk '(!/NAME/){print $1}' | xargs -n1 -J{} kubectl -n media patch pvc {} -p '{"metadata":{"finalizers": null}}'