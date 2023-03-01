param serviceBusNamespaceName string
param location string
param serviceBusApprovalQueueName string
param keyVaultName string
param serviceBusConnectionStringSecretName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
  }
  resource queue 'queues@2021-11-01' = {
    name: serviceBusApprovalQueueName
    properties: {
    }
  }
}

var endpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'

resource serviceBusConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVault.name}/${serviceBusConnectionStringSecretName}'
  properties: {
    value: 'Endpoint=sb://${serviceBusNamespace.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys(endpoint, serviceBusNamespace.apiVersion).primaryKey}'
  }
}

output serviceBusNamespaceName string = serviceBusNamespace.name
output serviceBusApprovalQueueName string = serviceBusApprovalQueueName
output serviceBusConnectionStringSecretName string = serviceBusConnectionStringSecretName
