export resourceGroupName=rg-tfstate-cac
export storageAccountName=ttesatfstatecac
export location=canadacentral

az group create --location $location --name $resourceGroupName
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS
az storage container create --name state --account-name $storageAccountName
az storage account blob-service-properties update --account-name $storageAccountName --enable-change-feed --enable-versioning true