
#!/bin/bash

# Set the CA certificate's validity period in days
VALIDITY_DAYS=365

# Create directory for the CA
mkdir vault-ca

# Generate a private key for the CA
openssl genrsa -out vault-ca/vault-ca.key 2048

# Create a self-signed CA certificate
openssl req -x509 -new -nodes -key vault-ca/vault-ca.key -sha256 -days ${VALIDITY_DAYS} -out vault-ca/vault-ca.pem -subj "/C=US/ST=California/L=San Francisco/O=HashiCorp/OU=CDL/CN=HashiCorp Vault Self-signed CA"
