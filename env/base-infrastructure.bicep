targetScope = 'subscription'

param resourcePrefix string = 'mfca'
param resourceGroupLocation string = 'westeurope'


resource hub_rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : '${resourcePrefix}-hub'
  location : resourceGroupLocation
}

resource spoke_rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : '${resourcePrefix}-spoke'
  location : resourceGroupLocation
}

// HUB

module hub_mod 'hub.bicep' = {
  name: '${resourcePrefix}-hub-resources'
  scope: hub_rg
  params: {
    resourcePrefix:  '${resourcePrefix}-hub'
    resourceGroupLocation: resourceGroupLocation
  }
}

// SPOKE

module spoke_mod 'spoke.bicep' = {
  name: '${resourcePrefix}-spoke-resources'
  scope: spoke_rg
  params: {
    resourcePrefix:  '${resourcePrefix}-spoke'
    resourceGroupLocation: resourceGroupLocation
  }
}


