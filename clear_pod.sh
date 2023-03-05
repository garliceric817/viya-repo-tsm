kubectl get pods | grep Terminating | awk '{print $1}' | xargs kubectl delete pod --force
kubectl get pods | grep Completed | awk '{print $1}' | xargs kubectl delete pod --force
kubectl get pods | grep Error | awk '{print $1}' | xargs kubectl delete pod 
kubectl get pods | grep CrashLoopBackOff | awk '{print $1}' | xargs kubectl delete pod --force
kubectl get pods | grep ImagePullBackOff | awk '{print $1}' | xargs kubectl delete pod
kubectl get pods | grep ContainerStatusUnknown | awk '{print $1}' | xargs kubectl delete pod
kubectl get pods | grep Evicted | awk '{print $1}' | xargs kubectl delete pod
kubectl get pods
