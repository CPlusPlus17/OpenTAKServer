#!/bin/bash

# Get the backend pod name
POD=$(kubectl get pods -n ots -l app.kubernetes.io/component=backend -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD" ]; then
    echo "Backend pod not found"
    exit 1
fi

echo "Found backend pod: $POD"

# Extract the CA certificate
kubectl exec -n ots $POD -- cat /app/data/ca/ca.pem > ca.crt

if [ ! -s ca.crt ]; then
    echo "Failed to extract ca.pem or file is empty"
    rm ca.crt
    exit 1
fi

echo "Extracted CA certificate to ca.crt"

# Create the secret
# Check if secret exists and delete if so
if kubectl get secret ots-ca-secret -n ots > /dev/null 2>&1; then
    echo "Deleting existing secret ots-ca-secret"
    kubectl delete secret ots-ca-secret -n ots
fi

kubectl create secret generic ots-ca-secret -n ots --from-file=ca.crt=ca.crt

echo "Created secret ots-ca-secret"

# Cleanup
rm ca.crt
