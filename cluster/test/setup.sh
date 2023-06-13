#!/usr/bin/env bash
set -aeuo pipefail

echo "exported server-token=${TOKEN}"
echo "Running setup.sh"
echo "Creating a default credentials..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: example-creds
  namespace: crossplane-system
type: Opaque
stringData:
  credentials: |
    {
      "
      "waypoint_addr: "waypoint.waypoint-system.svc.cluster.local",
      "token": \"${TOKEN}\"
    }
EOF

echo "Waiting until provider is healthy..."
${KUBECTL} wait provider.pkg --all --for condition=Healthy --timeout 5m

echo "Waiting for all pods to come online..."
${KUBECTL} -n upbound-system wait --for=condition=Available deployment --all --timeout=5m

echo "Creating a default provider config..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: waypoint.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: provider-secret
      namespace: upbound-system
      key: credentials
EOF