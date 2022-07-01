targetScope = 'subscription'

param resourcePrefix string = 'mfca'
param resourceGroupLocation string = deployment().location

var containerAppSubnetRange = '192.168.10.0/23'


resource hub_rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : '${resourcePrefix}-hub'
  location : resourceGroupLocation
}

resource spoke_rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : '${resourcePrefix}-spoke'
  location : resourceGroupLocation
}

module logging 'logging.bicep' = {
  name: '${resourcePrefix}-spoke-logging'
  scope: spoke_rg
  params: {
    resourcePrefix:  '${resourcePrefix}-spoke'
    resourceGroupLocation: resourceGroupLocation
  }
}

// NETWORK

module hub_network 'hub-network.bicep' = {
  name: '${resourcePrefix}-hub-network'
  scope: hub_rg
  params: {
    resourcePrefix:  resourcePrefix
    resourceGroupLocation: resourceGroupLocation
    logAnalyticsWorkspaceId: logging.outputs.logAnalyticsWorkspaceId
    containerAppSubnetRange: containerAppSubnetRange
  }
}

module spoke_network 'spoke-network.bicep' = {
  name: '${resourcePrefix}-spoke-network'
  scope: spoke_rg
  params: {
    resourcePrefix:  resourcePrefix
    resourceGroupLocation: resourceGroupLocation
    firewallIpAddress: hub_network.outputs.firewall_ip_address
    containerAppsInfraSubnetAddressSpace: containerAppSubnetRange
  }
}

module hub_to_spoke_peering 'vnetpeering.bicep' = {
  name: '${resourcePrefix}-hub-peering'
  scope: hub_rg
  params: {
    vnet1Name: hub_network.outputs.vnetName
    vnet2ResourceId: spoke_network.outputs.vnetId
    peeringName: 'peer-${hub_network.outputs.vnetName}-${spoke_network.outputs.vnetName}'
    allowForwardedTraffic : false
    useRemoteGateways : false
    allowGatewayTransit : true
  }
}

module spoke_to_hub_peering 'vnetpeering.bicep' = {
  name: '${resourcePrefix}-spoke-peering'
  scope: spoke_rg
  params: {
    vnet1Name: spoke_network.outputs.vnetName
    vnet2ResourceId: hub_network.outputs.vnetId
    peeringName: 'peer-${spoke_network.outputs.vnetName}-${hub_network.outputs.vnetName}'
    allowForwardedTraffic : false
    useRemoteGateways : false
    allowGatewayTransit : true
  }
  dependsOn: [ hub_to_spoke_peering ]
}



module containerappenvironment 'containerappenvironment.bicep' = {
  name: '${resourcePrefix}-spoke-cae'
  scope: spoke_rg
  params: {
    resourcePrefix:  '${resourcePrefix}-spoke'
    resourceGroupLocation: resourceGroupLocation
    containerAppsInfraSubnetId:  spoke_network.outputs.containerAppsInfraSubnetId
    AIConnectionString: logging.outputs.AIConnectionString
    AIInstrumentationKey:  logging.outputs.AIInstrumentationKey
    logAnalyticsCustomerId: logging.outputs.logAnalyticsCustomerId
    logAnalyticsSharedKey: logging.outputs.logAnalyticsSharedKey
  }
}




