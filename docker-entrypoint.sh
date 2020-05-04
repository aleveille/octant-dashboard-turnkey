#!/bin/sh
server=https://kubernetes.default.svc:443

OCTANT_HTTP_PORT=${OCTANT_HTTP_PORT:-8000}

ca=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 | tr -d '\n')
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

echo "
apiVersion: v1
kind: Config
clusters:
- name: k8s-on-premise
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: readonly-context
  context:
    cluster: k8s-on-premise
    namespace: ${namespace}
    user: octant-sa
current-context: readonly-context
users:
- name: octant-sa
  user:
    token: ${token}
" > /tmp/kubeconfig

exec /opt/octant --kubeconfig /tmp/kubeconfig --disable-open-browser --listener-addr 0.0.0.0:${OCTANT_HTTP_PORT}
