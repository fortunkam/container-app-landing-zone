param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

param vnetAddressSpace string = '192.168.0.0/21'
param firewallSubnetAddressSpace string = '192.168.0.0/24'
param vpnSubnetAddressSpace string = '192.168.1.0/24'
param apimSubnetAddressSpace string = '192.168.2.0/24'

// Spoke space will be at 192.168.8.0/21

resource hub_vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
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

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: 'AzureFirewallSubnet'
  parent: hub_vnet
  properties: {
    addressPrefix: firewallSubnetAddressSpace
  }
}

resource vpnSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: 'GatewaySubnet'
  parent: hub_vnet
  properties: {
    addressPrefix: vpnSubnetAddressSpace
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: 'APIMSubnet'
  parent: hub_vnet
  properties: {
    addressPrefix: apimSubnetAddressSpace
  }
}


