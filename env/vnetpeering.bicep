param vnet1Name string
param vnet2ResourceId string
param peeringName string
param allowForwardedTraffic bool
param useRemoteGateways bool
param allowGatewayTransit bool

resource peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet1Name}/${peeringName}'
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    useRemoteGateways: useRemoteGateways
    allowGatewayTransit: allowGatewayTransit
    remoteVirtualNetwork: {
      id: vnet2ResourceId
    }
  }
}
