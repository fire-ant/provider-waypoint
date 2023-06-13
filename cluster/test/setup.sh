#!/usr/bin/env bash
set -aeuo pipefail

# This segment is used to retrieve the server token from the waypoint-server-token secret
TOKEN=""
until [[ $TOKEN > 0 ]] && echo "exported server-token: ${TOKEN}" && [[ $TOKEN != "" ]]; do
  echo "Waiting for server token..."
  TOKEN=$(${KUBECTL} -n waypoint-system get secret waypoint-server-token -o json | jq -cr '.data | map_values(@base64d) | .token')
  sleep 1
done
# Now we can use the token to create a waypoint server client
echo "Running setup.sh"
echo "Creating a default credentials..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: provider-secret
  namespace: upbound-system
type: Opaque
stringData:
  credentials: |
    {
      "waypoint_addr": "waypoint-server.waypoint-system.svc.cluster.local:9701",
      "token": "$TOKEN"
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