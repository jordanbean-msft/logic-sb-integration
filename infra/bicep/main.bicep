param appName string
param region string
param environment string
param location string = resourceGroup().location

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    environment: environment
  }
}

module loggingDeployment 'logging.bicep' = {
  name: 'logging-deployment'
  params: {
    appInsightsName: names.outputs.appInsightsName
    logAnalyticsWorkspaceName: names.outputs.logAnalyticsWorkspaceName
    location: location
  }
}

module managedIdentityDeployment 'managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    location: location
    managedIdentityName: names.outputs.managedIdentityName
  }
}

module keyVaultDeployment 'key-vault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    keyVaultName: names.outputs.keyVaultName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    location: location
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
  }
}

module serviceBusDeployment 'service-bus.bicep' = {
  name: 'service-bus-deployment'
  params: {
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    location: location
    serviceBusConnectionStringSecretName: names.outputs.serviceBusNamespaceSecretName
    serviceBusNamespaceName: names.outputs.serviceBusNamespaceName
    serviceBusApprovalQueueName: names.outputs.serviceBusApprovalQueueName
  }
}

module logicAppDeployment 'logic-app.bicep' = {
  name: 'logic-app-deployment'
  params: {
    appInsightsName: loggingDeployment.outputs.appInsightsName
    logicAppName: names.outputs.logicAppName
    appServicePlanName: names.outputs.appServicePlanName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    serviceBusConnectionStringSecretName: serviceBusDeployment.outputs.serviceBusConnectionStringSecretName
    office365ConnectionKeySecretName: '' //names.outputs.office365ConnectionKeyStringSecretName
    logicAppStorageAccountConnectionStringSecretName: names.outputs.logicAppStorageAccountConnectionStringSecretName
    logicAppStorageAccountName: names.outputs.logicAppStorageAccountName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultDeployment.outputs.keyVaultName
}

module apiConnections 'api-connections.bicep' = {
  name: 'api-connections-deployment'
  params: {
    location: location
    office365ApiConnectionName: names.outputs.office365ApiConnectionName
    serviceBusApiConnectionName: names.outputs.serviceBusApiConnectionName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    office365ConnectionKeySecretName: names.outputs.office365ConnectionKeySecretName
    serviceBusConnectionString: keyVault.getSecret(serviceBusDeployment.outputs.serviceBusConnectionStringSecretName)
    logicAppName: logicAppDeployment.outputs.logicAppName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
  }
}
