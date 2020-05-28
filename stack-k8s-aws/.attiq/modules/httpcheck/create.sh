#!/bin/sh
# shellcheck disable=SC2154
kubectl config set-cluster ${cluster} \
  --embed-certs=true \
  --server=${server} \
  --certificate-authority=${ca_pem}

kubectl config set-credentials admin@${cluster} \
  --embed-certs=true \
  --certificate-authority=${ca_pem} \
  --client-key=${client_key} \
  --client-certificate=${client_pem}

kubectl config set-context ${cluster}  \
  --cluster=${cluster} \
  --user=admin@${cluster} \
  --namespace=${namespace}

[ "${use_context}" = "true" ] && kubectl config use-context ${cluster}

# shellcheck disable=SC2154
kubectl --context="${context}" --namespace=default delete ds/httpcheck
kubectl --context="${context}" --namespace=default delete jobs/httpcheck
cat <<EOF | kubectl --context="${context}" --namespace=default apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: httpcheck
spec:
  backoffLimit: 2
  activeDeadlineSeconds: 190
  parallelism: ${master_count}
  template:
    metadata:
      labels:
        pod-anti-affinity: httpcheck
    spec:
      hostNetwork: true
      restartPolicy: Never
      terminationGracePeriodSeconds: 1
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                pod-anti-affinity: httpcheck
            topologyKey: kubernetes.io/hostname
      containers:
      - name: httpcheck
        image: agilestacks/httpcheck:v0.0.2
        env:
        - name: HTTPCHECK_WAIT
          value: "180"
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      nodeSelector:
        node-role.kubernetes.io/master: ""
EOF
