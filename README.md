# Terraform AKS

## Requirements

### create backend 

which is required for terraform using the below command update the values accordingly

```bash
$ sh private_aks_terraform/pre-requisite/shell.sh
```

### Creating creds

```bash
$ az ad sp create-for-rbac \
  --role="Owner" \
  --scopes="/subscriptions/c2f4d38d-cfea-4b37-8620-2dbd9b242c4e"
```

You will be getting a json output the values are needed for terraform please export it as below
```bash
$ export ARM_CLIENT_ID=appId 
$ export ARM_SUBSCRIPTION_ID=subscription 
$ export ARM_TENANT_ID=tenant
$ export ARM_CLIENT_SECRET=password
```

### private_aks_cluster

To test the code, update the main.tf file with your Azure subscription ID.


## Usage

### Below commands are commands used

The init argument will initialize the environment.
```bash
$ terraform init
```
​
The plan argument will syntax check the files and prepare the deployment.
```bash
$ terraform plan -out vpc.plan
```
​
Deploy the VPC:
​
```bash
$ terraform apply vpc.plan
```
​
This will deploy the terraform in AWS:
​
```bash
$ terraform show
```
​
To destroy the setup done using terraform execute:
```bash
$ terraform destroy
```