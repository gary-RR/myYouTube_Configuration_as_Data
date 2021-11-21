
#Create a secret from literals.
kubectl create secret generic inventory \
    --from-literal=USERID=db-user1 \
    --from-literal=PASSWORD='pssWd@!70T5n%'


#View our "secret"
kubectl get secrets


#inventory said it had 2 Data elements, let's look
kubectl describe secret inventory


#If we need to access those at the command line...
#These are wrapped in bash expansion to add a newline to output for readability
echo $(kubectl get secret inventory --template={{.data.USERID}} )
echo $(kubectl get secret inventory --template={{.data.USERID}} | base64 --decode )

echo $(kubectl get secret inventory --template={{.data.PASSWORD}} )
echo $(kubectl get secret inventory --template={{.data.PASSWORD}} | base64 --decode )


#Accessing Secrets inside a POD as environment variables
kubectl apply -f deployment-secrets-env.yaml


PODNAME=$(kubectl get pods | grep hello-world-secrets-env | awk '{print $1}' | head -n 1)
echo $PODNAME

#Now let's get our enviroment variables from our container
#Our Enviroment variables from our Pod Spec are defined
kubectl exec -it $PODNAME -- /bin/sh
    printenv | sort 
exit

#Accessing Secrets as files
kubectl apply -f deployment-secrets-files.yaml

#Grab our pod name into a variable
PODNAME=$(kubectl get pods | grep hello-world-secrets-files | awk '{print $1}' | head -n 1)
echo $PODNAME

#Looking more closely at the Pod we see volumes, appsecrets and in Mounts...
kubectl describe pod $PODNAME

#Let's access a shell on the Pod
kubectl exec -it $PODNAME -- /bin/sh

    #Now we see the path we defined in the Volumes part of the Pod Spec
    #A directory for each KEY and it's contents are the value
    ls /etc/appsecrets
    cat /etc/appsecrets/USERID
    cat /etc/appsecrets/PASSWORD
exit

#Clean
kubectl delete secret inventory
kubectl delete deployment hello-world-secrets-env
kubectl delete deployment hello-world-secrets-files
