## Steps to Deploy Vault Enterprise

Please note that a Vault license is required

### 1. Generate the Certificate Authority (CA)
Before running `terraform apply`, you need to generate the Certificate Authority (CA) files required for Vault's TLS setup. So the nodes can comunicate between them using TLS

Run the following script to generate the CA:

```bash
cd utils
sh ca-gen.sh
```

### 2. Fill all the variables required for the deployment

There is a file called "terraform.tfvars.copy", define the variables you want to use and rename it to "terraform.tfvars"

### 3. Run the commands to start terraforming!

```bash
terraform init
terraform apply --auto-approve
```

Enjoy your Vault enterprise cluster!