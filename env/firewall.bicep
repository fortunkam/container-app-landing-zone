param resourcePrefix string
param resourceGroupLocation string = resourceGroup().location
param firewallSubnetId string
param logAnalyticsWorkspaceId string

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
        name: 'aks-outbound-azure-global'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'udp-vpn-azureglobal'
            ruleType: 'NetworkRule'
            destinationAddresses: [
              'AzureCloud.${resourceGroupLocation}'
            ]
            destinationPorts: [
              '1194'
            ]
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
          }
          {
            name: 'tcp-vpn-azureglobal'
            ruleType: 'NetworkRule'
            destinationAddresses: [
              'AzureCloud.${resourceGroupLocation}'
            ]
            destinationPorts: [
              '9000'
              '22'
            ]
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
          }
          {
            name: 'ntp-ubuntu'
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
          {
            name: 'azuremonitor'
            ruleType: 'NetworkRule'
            destinationAddresses: [
              'AzureMonitor'
            ]
            destinationPorts: [
              '443'
            ]
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
          }
        ]
        priority: 140
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
            name: 'container-apps'
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
              'vault.azure.net'
              'data.policy.core.windows.net'
              'store.policy.core.windows.net'
              'dc.services.visualstudio.com'
              '${resourceGroupLocation}.dp.kubernetesconfiguration.azure.com'
              'motd.ubuntu.com'
              'security.ubuntu.com'
              'azure.archive.ubuntu.com'
              'changelogs.ubuntu.com'
              '*.blob.core.windows.net'
              '*.blob.storage.azure.net'
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
          }
          {
            name: 'ubuntu'
            ruleType: 'ApplicationRule'
            targetFqdns: [
              'security.ubuntu.com'
              'azure.archive.ubuntu.com'
              'changelogs.ubuntu.com'
            ]
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
            ]
            sourceAddresses: [
              '*'
            ]
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

resource fwDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  {
  scope: firewall
  name: 'fwDiags'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}



output firewall_ip_address string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
