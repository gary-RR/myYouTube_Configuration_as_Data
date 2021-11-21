#Review the "inventry secret" created in the previous demo
kubectl describe secret inventory

#Play the role of a hacker and get secrets
sudo ETCDCTL_API=3 etcdctl --endpoints=192.168.0.22:2379 \
        --cert=/etc/kubernetes/pki/etcd/server.crt \
        --key=/etc/kubernetes/pki/etcd/server.key \
        --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        get /registry/secrets/default/inventory | hexdump -C

#To enable encrypting secrets at rest

    #Generate a 32 byte random key and base64 encode it
    head -c 32 /dev/urandom | base64

    #Edit the sample EncryptionConfiguration.yaml and add the ky generted above to the "secret:" section

    #Copy encryption config file under "/etc/kubernetes/pki"    
    sudo cp EncryptionConfiguration.yaml /etc/kubernetes/pki

    #Edit the "kube-apiserver.yaml" and add "--encryption-provider-config=/etc/kubernetes/pki/EncryptionConfiguration.yaml"
    sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml

    #Restart server

#Check the secret again
sudo ETCDCTL_API=3 etcdctl --endpoints=192.168.0.22:2379 \
        --cert=/etc/kubernetes/pki/etcd/server.crt \
        --key=/etc/kubernetes/pki/etcd/server.key \
        --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        get /registry/secrets/default/inventory | hexdump -C

#Since secrets are encrypted on write, to encrypt all, performing an update on a secret will encrypt that content
kubectl get secrets --all-namespaces -o json | kubectl replace -f -


#Check the secret again. Verify the stored secret is prefixed with k8s:enc:aescbc:v1: which indicates the aescbc provider has encrypted the resulting data.
sudo ETCDCTL_API=3 etcdctl --endpoints=192.168.0.22:2379 \
        --cert=/etc/kubernetes/pki/etcd/server.crt \
        --key=/etc/kubernetes/pki/etcd/server.key \
        --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        get /registry/secrets/default/inventory | hexdump -C


# Rotating a decryption key 
# Changing the secret without incurring downtime requires a multi step operation, especially in the presence of a highly available deployment where multiple kube-apiserver processes are running.

# Generate a new key and add it as the second key entry for the current provider on all servers
# Restart all kube-apiserver processes to ensure each server can decrypt using the new key
# Make the new key the first entry in the keys array so that it is used for encryption in the config
# Restart all kube-apiserver processes to ensure each server now encrypts using the new key
# Run kubectl get secrets --all-namespaces -o json | kubectl replace -f - to encrypt all existing secrets with the new key
# Remove the old decryption key from the config after you back up etcd with the new key in use and update all secrets
# With a single kube-apiserver, step 2 may be skipped

