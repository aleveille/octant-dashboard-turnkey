#!/bin/sh
echo "Starting Octant docker container"

server=https://kubernetes.default.svc:443

OCTANT_HTTP_PORT=${OCTANT_HTTP_PORT:-8000}
OCTANT_PLUGINS_DIR=${OCTANT_PLUGINS_DIR%/}
OCTANT_PLUGINS_DIR=${OCTANT_PLUGINS_DIR:-/home/octant/.config/octant/plugins}

echo "Grabbing Kubernetes pod secret to access API and list resources"
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

if [[ "${OCTANT_PLUGINS_DIR}" != "${HOME}/.config/octant/plugins" ]]; then
  echo "Adding ${OCTANT_PLUGINS_DIR} to plugins dir because it is different than ${HOME}/.config/octant/plugins"
  ADDITIONAL_OCTANT_ARGUMENT="--plugin-path ${OCTANT_PLUGINS_DIR}"
fi

echo "Launching the Octant process (as $(whoami) user):"
exec /opt/octant --kubeconfig /tmp/kubeconfig $ADDITIONAL_OCTANT_ARGUMENT --disable-open-browser --listener-addr 0.0.0.0:${OCTANT_HTTP_PORT}
