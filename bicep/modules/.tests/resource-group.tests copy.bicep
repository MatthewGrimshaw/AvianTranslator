
// Test with only required parameters
module test_required_params '../resource-group.bicep' = {
  scope: subscription()
  name: 'test_required_params'
  params: {
    resourceGroupName: 'rgname'
    location: 'westeurope'
    tags:{
      env: 'prod'
      }
 }
}
