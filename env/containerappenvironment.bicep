param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

param containerAppsInfraSubnetId string
param logAnalyticsCustomerId string
param logAnalyticsSharedKey string
param AIConnectionString string
param AIInstrumentationKey string

resource container_app_env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${resourcePrefix}-container-apps-env'
  location: resourceGroupLocation
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
    daprAIConnectionString: AIConnectionString
    daprAIInstrumentationKey: AIInstrumentationKey
    vnetConfiguration: {
      infrastructureSubnetId: containerAppsInfraSubnetId
      internal: true
    }
    zoneRedundant: false
  }
}
