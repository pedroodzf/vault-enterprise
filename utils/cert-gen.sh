#!/bin/bash

# Check if two arguments were passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 IP_ADDRESS1 IP_ADDRESS2"
    exit 1
fi

# Assign the first and second argument to IP_ADDRESS1 and IP_ADDRESS2
IP_ADDRESS1=$1
IP_ADDRESS2=$2
VALIDITY_DAYS=3

# Generate a private key for the server
openssl genrsa -out "vault-key.pem" 2048

# Create a certificate signing request (CSR) for the server
openssl req -new -key "vault-key.pem" -out "vault-cert.csr" -subj "/C=US/ST=California/L=San Francisco/O=HashiCorp/OU=CDL/CN=${IP_ADDRESS1}"

# Start building the server certificate extension file
cat > "${IP_ADDRESS1}.ext" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = ${IP_ADDRESS1}
IP.2 = ${IP_ADDRESS2}
IP.3 = 127.0.0.1
DNS.1 = vault-cluster
EOF

# Generate the server certificate signed by the CA
openssl x509 -req -in "vault-cert.csr" -CA vault-ca.pem -CAkey vault-ca.key -CAcreateserial -out "vault-cert.pem" -days ${VALIDITY_DAYS} -sha256 -extfile "${IP_ADDRESS1}.ext"

# Create the chain file by concatenating the server certificate and the CA certificate
cat "vault-cert.pem" vault-ca.pem > "vault-chain.pem"

# Cleanup
rm "vault-cert.csr"
rm "${IP_ADDRESS1}.ext"

echo "Certificates generated successfully."