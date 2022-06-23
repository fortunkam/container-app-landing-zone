param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location
param firewallSubnetId string

resource ip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${resourcePrefix}-ip'
  location: resourceGroupLocation
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall_policy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: '${resourcePrefix}-policy'
  location: resourceGroupLocation
  properties: {
    sku: {
      tier : 'Standard'
    }
    threatIntelMode: 'Alert'
    dnsSettings: {
      enableProxy: true
    }
  }
}

resource firewall_policy_rules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  name: '${resourcePrefix}-rules'
  parent: firewall_policy
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'containerapps-outbound-ntp'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            destinationFqdns: [
              'ntp.ubuntu.com'
            ]
            destinationPorts: [
              '123'
            ]
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
          }
        ]
        priority: 150
      }
      {
        name: 'containerapps-outbound-fqdn'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        priority: 200
        rules: [
          {
            ruleType: 'ApplicationRule'
            targetFqdns: [
              '*.hcp.${resourceGroupLocation}.azmk8s.io'
              'mcr.microsoft.com'
              '*.data.mcr.microsoft.com'
              'management.azure.com'
              'login.microsoftonline.com'
              'packages.microsoft.com'
              'acs-mirror.azureedge.net'
              'dc.services.visualstudio.com'
              '*.ods.opinsights.azure.com'
              '*.oms.opinsights.azure.com'
              '*.monitoring.azure.com'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            sourceAddresses: [
              '*'
            ]
            fqdnTags: []
            webCategories: []
            targetUrls: []
            terminateTLS: false
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: resourcePrefix
  location: resourceGroupLocation
  properties: {
    sku: {
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewall_policy.id
    }
    ipConfigurations: [
      {
        name: '${resourcePrefix}-ip-config'
        properties: {
          publicIPAddress: {
            id: ip.id
          }
          subnet: {
            id: firewallSubnetId
          }
        }
      }
    ]
  }
}



output firewall_ip_address string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
