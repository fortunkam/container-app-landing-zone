param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

//VNET


module hub_vnet_mod 'hub-network.bicep' = {
  name: '${resourcePrefix}-network'
  params: {
    resourcePrefix: resourcePrefix
    resourceGroupLocation: resourceGroupLocation
  }
}
