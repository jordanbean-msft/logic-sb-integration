param serviceBusApiConnectionName string
param office365ApiConnectionName string
param location string
param office365ConnectionKeySecretName string
param keyVaultName string
@secure()
param serviceBusConnectionString string
param logicAppName string
param managedIdentityName string

resource logicApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: logicAppName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
}

resource serviceBusApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: serviceBusApiConnectionName
  location: location
  kind: 'V2'
  properties: {
    displayName: serviceBusApiConnectionName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    }
    parameterValues: {
      connectionString: serviceBusConnectionString
    }
  }
  resource accessPolices 'accessPolicies@2016-06-01' = {
    name: logicAppName
    location: location
    properties: {
      principal: {
        type: 'ActiveDirectory'
        identity: {
          objectId: managedIdentity.properties.principalId
          tenantId: subscription().tenantId
        }
      }
    }
  }
}

resource office365ApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: office365ApiConnectionName
  location: location
  kind: 'V2'
  properties: {
    displayName: office365ApiConnectionName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    }
  }
  resource accessPolices 'accessPolicies@2016-06-01' = {
    name: logicAppName
    location: location
    properties: {
      principal: {
        type: 'ActiveDirectory'
        identity: {
          objectId: managedIdentity.properties.principalId
          tenantId: subscription().tenantId
        }
      }
    }
  }
}

output office365ConnectionKeyStringSecretName string = office365ConnectionKeySecretName
