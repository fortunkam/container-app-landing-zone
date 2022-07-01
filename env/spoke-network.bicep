param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location


param spokeVnetAddressSpace string = '192.168.8.0/21'
param containerAppsInfraSubnetAddressSpace string

param firewallIpAddress string

var spokeResourcePrefix = '${resourcePrefix}-spoke'

resource firewallRouteTable 'Microsoft.Network/routeTables@2021-08-01' = {
  name:  '${spokeResourcePrefix}-firewall-routetable'
  location : resourceGroupLocation
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: '${spokeResourcePrefix}-firewall-route'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: firewallIpAddress
          nextHopType: 'VirtualAppliance'
        }
        type: 'string'
      }
    ]
  }
}

module nsg 'nsg.bicep' = {
  name: '${spokeResourcePrefix}-nsg-deploy'
  params: {
    resourcePrefix:  spokeResourcePrefix
    resourceGroupLocation: resourceGroupLocation
    containerAppsInfraSubnetAddressSpace: containerAppsInfraSubnetAddressSpace
  }
}

resource spoke_vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name : '${spokeResourcePrefix}-vnet'
  location : resourceGroupLocation
  properties : {
    addressSpace : {
      addressPrefixes : [
        spokeVnetAddressSpace
      ]
      
    }
    // dhcpOptions: {
    //   dnsServers: [
    //     firewallIpAddress
    //   ]
    // }
    subnets : [
      {
        name: 'containerAppsInfraSubnet'
        properties: {
          addressPrefix: containerAppsInfraSubnetAddressSpace
          routeTable : {
            id: firewallRouteTable.id
          }
          networkSecurityGroup: {
            id: nsg.outputs.nsgId
          }
        }
      }
    ]
  }
}



output vnetName string = spoke_vnet.name
output vnetId string =spoke_vnet.id
output containerAppsInfraSubnetId string = spoke_vnet.properties.subnets[0].id






