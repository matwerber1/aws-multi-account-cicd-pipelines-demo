# This file contains environment vars that we will source for use in our scripts:

# These profiles should match the profiles you have configured for your AWS CLI.
# You can check the ~/.aws/config file to view or edit your profile names. Note, 
# if you change a profile name, you will also need to make the same change to 
# to ~/.aws/credentials: 
export DEVOPS_PROFILE="your_devops_profile"
export TEST_PROFILE="your_test_profile"
export PROD_PROFILE="your_prod_profile"

export DEVOPS_ACCOUNT_ID="111111111111"
export TEST_ACCOUNT_ID="222222222222"
export PROD_ACCOUNT_ID="333333333333"

# These values are used for the devOps resources shared by all of our pipelines:
export DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME="devops-pipeline-resources"
export DEVOPS_PIPELINE_SERVICE_ROLE_NAME="devops-codepipeline-service-role"
export DEVOPS_CODFEPIPELINE_BUCKET_NAME="${DEVOPS_ACCOUNT_ID}-codepipeline-devops-artifacts"

# Name of the stack that we deploy in test/prod to create cross-account roles:
export CROSS_ACCOUNT_RESOURCES_STACK_NAME="crossaccount-deployment-roles"

# These values correspond with each of the demo pipelines we will create: 
export DEVOPS_INFRASTRUCTURE_REPO_NAME="devops-infrastructure"
export DEVOPS_INFRASTRUCTURE_PIPELINE_NAME="devops-infrastructure-pipeline"
export INFRASTRUCTURE_CLOUDFORMATION_STACK_NAME="devops-infrastructure-stack"   # This is the stack name that the pipeline will create in the test and prod accounts
