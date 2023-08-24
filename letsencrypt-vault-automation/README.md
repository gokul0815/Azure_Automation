# Terraform AKS & Letsencrypt automation


## SSL Certificate Management with Let's Encrypt

### Things to know

#### What is Posh-ACME

Posh-ACME is designed to orchestrate the issuance with an ACME compatible certificate authority (in our case, Let’s Encrypt). Our build pipeline wraps the Posh-ACME capabilities with holistic management of the stateful data. Subsequent processes can utilise the certificate/keys once they’re imported into Key Vault. 

Posh-ACME is stateful. Posh-ACME stores ACME server information, certificate order details, certificates, and private keys on the file system. We’ll persist all this data to Blob storage. We enable HTTPS Traffic Only as this storage account contains sensitive private keys which should not be transferred without encryption. Change the SKU to meet your redundancy requirements.


### Setup


#### DNS Zone: 

Change the Name parameter to your domain name.

```bash
$ New-AzDnsZone -Name "ttegokuldevops.tk" -ResourceGroupName "acme"
```

#### Blob Storage:

Change the storage account Name parameter to be globally unique.


```bash
$ New-AzStorageAccount -Name "acmecerts" -ResourceGroupName "acme" -Location "canadacentral" -Kind StorageV2 -SkuName Standard_LRS -EnableHttpsTrafficOnly $true
$ storageAccountKey = Get-AzStorageAccountKey -Name "acmecerts" -ResourceGroupName "acme" | Select-Object -First 1 -ExpandProperty Value
$ storageContext = New-AzStorageContext -StorageAccountName "acmecerts" -StorageAccountKey $storageAccountKey
$ New-AzStorageContainer -Name "poshacme" -Context $storageContext
```

#### Keyvault 


```bash
$ New-AzKeyVault -Name "acmecerts" -ResourceGroupName "acme" -Location "canadacentral" -EnablePurgeProtection -EnableSoftDelete

```

### Azure DevOps

#### Create the service principal

The build pipeline uses a service connection to control Azure resources. We’ll define the build pipeline in YAML format, and store it inside an Azure Repos Git repository.

We’ll create an Azure service principal with just enough permissions to our Azure resources using Az PowerShell.

```bash
$ application = New-AzADApplication -DisplayName "ACME Certificate Automation" -IdentifierUris "http://brentrobinson.info/acme"
$ servicePrincipal = New-AzADServicePrincipal -ApplicationId $application.ApplicationId
$ servicePrincipalCredential = New-AzADServicePrincipalCredential -ServicePrincipalObject $servicePrincipal -EndDate (Get-Date).AddYears(5)
```

Once created, we can view the service principal client id and password secret with these commands.

```bash
$ Write-Output ("Client ID     = {0}" -f $servicePrincipal.ApplicationId)
$ Write-Output ("Client Secret = {0}" -f [System.Net.NetworkCredential]::new([string]::Empty, $servicePrincipalCredential.Secret).Password)
```

#### Grant the service principal access to the resources

We’ll grant DNS Zone Contributor on the DNS Zone to enable Posh-ACME to create the DNS challenge TXT records for domain validation.

```bash
$ New-AzRoleAssignment -ObjectId $servicePrincipal.Id -ResourceGroupName "acme" -ResourceName "brentrobinson.info" -ResourceType "Microsoft.Network/dnszones" -RoleDefinitionName "DNS Zone Contributor"
```

We’ll grant the service principal access to read the key vault, on the control plane. We’ll also grant access to the data plane. Get Certificate allows us to check if we’ve been issued a newer certificate by examining the thumbprint of the certificate in Key Vault. Import Certificate allows us to import issues certificates into the Key Vault.


```bash
$ New-AzRoleAssignment -ObjectId $servicePrincipal.Id -ResourceGroupName "acme" -ResourceName "acmecerts" -ResourceType "Microsoft.KeyVault/vaults" -RoleDefinitionName "Reader"
$ Set-AzKeyVaultAccessPolicy -ResourceGroupName "acme" -VaultName "acmecerts" -ObjectId $servicePrincipal.Id -PermissionsToCertificates Get, Import
```

We’ll generate a SAS token to access the data in the Azure Storage container.

```bash
$ storageAccountKey = Get-AzStorageAccountKey -Name "acmecerts" -ResourceGroupName "acme" | Select-Object -First 1 -ExpandProperty Value
$ storageContext = New-AzStorageContext -StorageAccountName "acmecerts" -StorageAccountKey $storageAccountKey
$ New-AzStorageContainerSASToken -Name "poshacme" -Permission rwdl -Context $storageContext -FullUri -ExpiryTime (Get-Date).AddYears(5)
```

#### Create a service connection



#### Clone the repository with the pipeline definition

 Azure DevOps project, open Repos and select Import Repository

 Enter the Clone URL: https://github.com/gokul0815/Azure_Automation.git

#### Create the build pipeline

