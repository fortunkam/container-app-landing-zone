param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

//VNET


module spoke_vnet_mod 'spoke-network.bicep' = {
  name: '${resourcePrefix}-network'
  params: {
    resourcePrefix: resourcePrefix
    resourceGroupLocation: resourceGroupLocation
  }
}
