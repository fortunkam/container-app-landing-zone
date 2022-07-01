param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location

param containerAppsInfraSubnetAddressSpace string


resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${resourcePrefix}-nsg'
  location: resourceGroupLocation
  properties: {
    securityRules: [
      {
        name: 'inbound_to_infra_subnet'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: containerAppsInfraSubnetAddressSpace
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'inbound_from_loadbalancer'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 190
          direction: 'Inbound'
        }
      }
      {
        name: 'outbound_to_azure_cloud_udp'
        properties: {
          protocol: 'UDP'
          sourcePortRange: '*'
          destinationPortRange: '1194'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud.${resourceGroupLocation}'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'outbound_to_azure_cloud_tcp'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '9000'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud.${resourceGroupLocation}'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'outbound_to_azure_monitor'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'outbound_to_https'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'outbound_to_ntp'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '123'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'outbound_to_infra_subnet'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: containerAppsInfraSubnetAddressSpace
          access: 'Allow'
          priority: 180
          direction: 'Outbound'
        }
      }
    ]
  }
}


output nsgId string = nsg.id
