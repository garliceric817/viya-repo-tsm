kubectl apply --selector="sas.com/admin=cluster-api" -f site.yaml
kubectl wait --for condition=established --timeout=60s -l "sas.com/admin=cluster-api" crd
kubectl apply -f site.yaml --selector="sas.com/admin=cluster-wide"

kubectl apply --selector="sas.com/admin=cluster-local" -f site.yaml --prune
kubectl apply --selector="sas.com/admin=namespace" -f site.yaml --prune
kubectl apply --selector="sas.com/admin=namespace" -f site.yaml --prune --prune-whitelist=autoscaling/v2beta2/HorizontalPodAutoscaler

