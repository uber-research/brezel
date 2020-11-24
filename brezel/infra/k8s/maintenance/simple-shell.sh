#!/bin/bash
# Use this script to get an interactive shell on the cluster.
# The pod is automatically deleted at the end.

create_pod () {
    # The nodepool where the maintenance pod should be started
    readonly NODEPOOL='pool-experiments'

    # The container image of the pod (here debian-based with google cloud sdk)
    readonly IMAGE='gcr.io/google.com/cloudsdktool/cloud-sdk:slim'

    # local script you want to include in the pod (optional)
    readonly SCRIPT="$1"

    # Request pod
    readonly PODNAME="$(whoami)-maintenance-shell"
    cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${PODNAME}
spec:
  containers:
  - name: maintenance
    image: ${IMAGE}
    args:
    - sleep
    - infinity
  nodeSelector:
    cloud.google.com/gke-nodepool: ${NODEPOOL}
EOF
}

# if the first argument is a yaml file, we use it
if [[ "${1:-}" == *.yaml ]]; then
    readonly PODNAME=$(awk '/^ *name/ {print $NF}' "${1}")
    kubectl create -f - < "${1}"
    shift
# otherwise we create the pod from the template above
else
    create_pod
fi

# Wait for the pod to be ready
sleep 1
pod_ready () {
    local status=$(kubectl get pods "${PODNAME}" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
    [[ "$status" == "True" ]]
}
while ! pod_ready; do echo "waiting for pod..." && sleep 5; done

# Include local script in pod
if [[ -s "${SCRIPT}" ]]; then
    kubectl cp "${SCRIPT}"  "${PODNAME}:/"
fi

# Start interactive shell
kubectl exec -it "${PODNAME}" -- bash

# Delete pod
kubectl delete pod "${PODNAME}"
