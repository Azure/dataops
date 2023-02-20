@description('Conditional resource creation')
param deployStorage bool
param deployADF bool
param deployprojectName bool

@description('Data Factory Name')
param dataFactoryName string

@description('Storage SKU')
param storageSKU string

@description('Location of the data factory.')
param location string = resourceGroup().location

@description('Name of the Azure storage account that contains the input/output data.')
param storageAccountName string

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string = 'blob${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = if (deployStorage) {
  name: storageAccountName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = if (deployStorage) {
  name: '${storageAccount.name}/default/${blobContainerName}'
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = if (deployADF) {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}


@description('Specifies a project name that is used to generate the Event Hub name and the Namespace name.')
param projectName string
@description('Specifies the messaging tier for Event Hub Namespace.')
@allowed([
  'Basic'
  'Standard'
])
param eventHubSku string = 'Standard'

var eventHubNamespaceName = '${projectName}ns'
var eventHubName = projectName

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01'  = if (deployprojectName) {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = if (deployprojectName)  {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}
