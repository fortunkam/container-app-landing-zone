param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${resourcePrefix}-log-analytics'
  location: resourceGroupLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${resourcePrefix}-app-insights'
  location: resourceGroupLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: 30
  }
}

output logAnalyticsCustomerId string = logAnalytics.properties.customerId
output logAnalyticsSharedKey string = logAnalytics.listKeys().primarySharedKey
output AIConnectionString string = appInsights.properties.ConnectionString
output AIInstrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsWorkspaceId string = logAnalytics.id
