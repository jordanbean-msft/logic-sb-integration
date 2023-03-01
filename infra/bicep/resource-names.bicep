param appName string
param region string
param environment string

output appServicePlanName string = 'asp-${appName}-${region}-${environment}'
output logicAppName string = 'logic-${appName}-${region}-${environment}'
output managedIdentityName string = 'mi-${appName}-${region}-${environment}'
output keyVaultName string = 'kv${appName}${region}${environment}'
output appInsightsName string = 'ai-${appName}-${region}-${environment}'
output logAnalyticsWorkspaceName string = 'la-${appName}-${region}-${environment}'
output serviceBusNamespaceName string = 'sb-${appName}-${region}-${environment}'
output serviceBusApprovalQueueName string = 'approval-queue'
output serviceBusNamespaceSecretName string = 'service-bus-connection-string'
output office365ConnectionKeySecretName string = 'office365-connectionKey'
output serviceBusApiConnectionName string = 'serviceBus'
output office365ApiConnectionName string = 'office365'
output logicAppStorageAccountName string = toLower('sa${uniqueString('logic-${appName}-${region}-${environment}')}')
output logicAppStorageAccountConnectionStringSecretName string = 'logic-app-storage-account-connection-string'
