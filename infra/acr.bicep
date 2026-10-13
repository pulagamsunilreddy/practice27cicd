targetScope = 'resourceGroup'

@description('Globally unique container registry name.')
@minLength(5)
@maxLength(50)
param acrName string

@description('Azure region for the registry.')
param location string = resourceGroup().location

resource registry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: acrName
  location: location

  sku: {
    name: 'Basic'
  }

  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Enabled'
  }

  tags: {
    project: 'practice27cicd'
    purpose: 'learning'
  }
}

output registryName string = registry.name
output loginServer string = registry.properties.loginServer
output registryId string = registry.id