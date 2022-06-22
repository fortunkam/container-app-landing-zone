param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

param vnetAddressSpace string = '192.168.8.0/21'
param containerAppsSubnetAddressSpace string = '192.168.8.0/23'


resource spoke_vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name : '${resourcePrefix}-vnet'
  location : resourceGroupLocation
  properties : {
    addressSpace : {
      addressPrefixes : [
        vnetAddressSpace
      ]
    }
  }
}

resource containerAppsSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: 'containerAppsSubnet'
  parent: spoke_vnet
  properties: {
    addressPrefix: containerAppsSubnetAddressSpace
  }
}




