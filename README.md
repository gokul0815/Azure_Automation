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
$ terraform plan -out private_aks_terraform.plan
```
​
Deploy the VPC:
​
```bash
$ terraform apply private_aks_terraform.plan
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


## Sample app deployment

We are using the azure sample app to deployed in this.

Note: The whole setup works on default namespace in helm commands please specify -n namespace to use custom one.

### Create Docker file

Create the docker using the below command.

```bash
$ git clone https://github.com/Azure-Samples/azure-voting-app-redis.git
$ cd azure-voting-app-redis/azure-vote/
$ az acr build --image azure-vote-front:v1 --registry tteacrpvakscac --file Dockerfile .
```

### Create Helm Charts

Create helm charts using the below command

```bash
$ helm create azure-vote-front
```

Update azure-vote-front/Chart.yaml to add a dependency for the redis chart from the https://charts.bitnami.com/bitnami chart repository


Update dependency

```bash
$ helm dependency update azure-vote-front
```

Update Image


Update the docker image which has been published in azure-vote-front/values.yaml

### Helm Install

Using the below command apply the chart

```bash
$ helm install azure-vote-front azure-vote-front/
```

It takes a few minutes for the service to return a public IP address. Monitor progress using the kubectl get service command with the --watch argument.

### Helm Install

The above applied setup can be removed using below command.


```bash
$ helm uninstall azure-vote-front
```



