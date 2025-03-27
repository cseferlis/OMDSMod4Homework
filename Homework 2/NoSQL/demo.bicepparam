using './template/template.bicep'

param databaseName = 'omdsmod4'
param containerName = 'movies'
param partitionKeyPath = '/status'
param throughput = 400
