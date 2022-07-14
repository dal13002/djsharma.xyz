#! /bin/sh

# Apply the calico rules via the downloaded calico config
# We are hardcoding the cloudflare cidrs here but that is okay...
# the real solution (write calico provider) would not use this
cat <<EOF | calicoctl --allow-version-mismatch apply -c ${CONFIGFILE} -f - 
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: allow-all-cloudflare
spec:
  ingress:
  - action: "Allow"
    destination: {}
    source:
      nets:
      - 103.21.244.0/22
      - 103.22.200.0/22
      - 103.31.4.0/22
      - 104.16.0.0/13
      - 104.24.0.0/14
      - 108.162.192.0/18
      - 131.0.72.0/22
      - 141.101.64.0/18
      - 162.158.0.0/15
      - 172.64.0.0/13
      - 173.245.48.0/20
      - 188.114.96.0/20
      - 190.93.240.0/20
      - 197.234.240.0/22
      - 198.41.128.0/17
  order: 500
  selector: ibm.role in { 'worker_public', 'master_public' }
  types:
  - Ingress
EOF
