
#Create a PROD ConfigMap from literals
kubectl create configmap inventory-configmap-prod \
    --from-literal=SV_EXTERNAL_SERVICE_HOST_NAME=server1.acme.org \
    --from-literal=SV_PORT_NUMBER=9001

#Create a Stage ConfigMap from files or from directories
#If no key, then the base name of the file
#Otherwise we can specify a key name to allow for more complex app configs and access to specific configuration elements
cat inventory-configmap-stage.txt
kubectl create configmap inventory-configmap-stage \
    --from-file=inventory-configmap-stage.txt


#Each creation method yeilded a different structure in the ConfigMap
kubectl get configmap inventory-configmap-prod -o yaml
kubectl get configmap inventory-configmap-stage -o yaml


#Load pord ConfigMaps in Pod as environment variables
kubectl apply -f deployment-configmaps-env-prod.yaml

#Let's see or configured enviroment variables
PODNAME=$(kubectl get pods | grep hello-world-configmaps-env-prod | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
    printenv | sort
exit


#Load stage ConfigMaps in Pod as files
kubectl apply -f deployment-configmaps-files-stage.yaml

#Let's see our configmap exposed as a file using the key as the file name.
PODNAME=$(kubectl get pods | grep hello-world-configmaps-files-stage | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
    ls /etc/inventory-configmap-stage
    cat /etc/inventory-configmap-stage/inventory-configmap-stage.txt
exit


#Updating a configmap, change SV_PORT_NUMBE to 9004
kubectl edit configmap inventory-configmap-stage


kubectl exec -it $PODNAME -- /bin/sh 
    watch cat /etc/inventory-configmap-stage/inventory-configmap-stage.txt
exit


#Cleaning up our demp
kubectl delete deployment hello-world-configmaps-env-prod
kubectl delete deployment hello-world-configmaps-files-stage

