targetScope = 'resourceGroup'

@description('Name of the AKS cluster.')
param clusterName string = 'aks-practice27'

@description('Azure region.')
param location string = resourceGroup().location

resource cluster 'Microsoft.ContainerService/managedClusters@2025-05-01' = {
  name: clusterName
  location: location

  tags: {
    project: 'practice27cicd'
    purpose: 'learning'
  }

  sku: {
    name: 'Base'
    tier: 'Free'
  }

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    dnsPrefix: clusterName

    enableRBAC: true
    disableLocalAccounts: true

    aadProfile: {
      managed: true
      enableAzureRBAC: true
      tenantID: subscription().tenantId
    }

    agentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        count: 2
        vmSize: 'Standard_D4s_v3'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        osDiskType: 'Managed'
        osDiskSizeGB: 128
        maxPods: 30
        enableAutoScaling: false
      }
    ]

    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      podCidr: '10.244.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'

      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 1
        }
      }
    }

    apiServerAccessProfile: {
      enablePrivateCluster: false
    }

    oidcIssuerProfile: {
      enabled: true
    }

    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterName string = cluster.name
output clusterId string = cluster.id
output nodeResourceGroup string = cluster.properties.nodeResourceGroup