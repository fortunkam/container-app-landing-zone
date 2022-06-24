param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

var hubResourcePrefix = '${resourcePrefix}-hub'

param hubVnetAddressSpace string = '192.168.0.0/21'
param firewallSubnetAddressSpace string = '192.168.0.0/24'
param vpnSubnetAddressSpace string = '192.168.1.0/24'
param apimSubnetAddressSpace string = '192.168.2.0/24'
param logAnalyticsWorkspaceId string


resource hub_vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name : '${hubResourcePrefix}-vnet'
  location : resourceGroupLocation
  properties : {
    addressSpace : {
      addressPrefixes : [
        hubVnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetAddressSpace
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: vpnSubnetAddressSpace
        }
      }
      {
        name: 'APIMSubnet'
        properties: {
          addressPrefix: apimSubnetAddressSpace
        }
      }
    ]
  }
}

module firewall_deploy 'firewall.bicep' = {
  name: '${resourcePrefix}-firewall-deploy'
  params: {
    resourcePrefix:  '${resourcePrefix}-firewall'
    resourceGroupLocation: resourceGroupLocation
    firewallSubnetId: hub_vnet.properties.subnets[0].id
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


output vnetName string = hub_vnet.name
output vnetId string = hub_vnet.id
output firewall_ip_address string = firewall_deploy.outputs.firewall_ip_address






