# This file contains environment vars that we will source for use in our scripts:

# These profiles should match the profiles you have configured for your AWS CLI.
# You can check the ~/.aws/config file to view or edit your profile names. Note, 
# if you change a profile name, you will also need to make the same change to 
# to ~/.aws/credentials: 
export DEVOPS_PROFILE="<your_devops_cli_profile>"
export TEST_PROFILE="<your_test_cli_profile>"
export PROD_PROFILE="<your_prods_cli_profile>"

export DEVOPS_ACCOUNT_ID="111111111111"
export TEST_ACCOUNT_ID="222222222222"
export PROD_ACCOUNT_ID="333333333333"

# These values are used for the devOps resources shared by all of our pipelines:
export DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME="devops-pipeline-resources"
export DEVOPS_PIPELINE_SERVICE_ROLE_NAME="devops-codepipeline-service-role"
export DEVOPS_CODEBUILD_SERVICE_ROLE_NAME="decops-codebuild-service-role"
export DEVOPS_CODFEPIPELINE_BUCKET_NAME="${DEVOPS_ACCOUNT_ID}-codepipeline-devops-artifacts"

# Name of the stack that we deploy in test/prod to create cross-account roles:
export CROSS_ACCOUNT_RESOURCES_STACK_NAME="crossaccount-deployment-roles"

# Name of the role that will be created in test/prod accounts that our pipeline in DevOps
# assumes to perform cross-account deployment actions: 
export CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_NAME="devops-crossaccount-pipeline-deloyment-role"

# These values correspond with each of the demo pipelines we will create: 
export DEVOPS_INFRASTRUCTURE_REPO_NAME="devops-infrastructure"
export DEVOPS_INFRASTRUCTURE_PIPELINE_NAME="devops-infrastructure-pipeline"
export INFRASTRUCTURE_CLOUDFORMATION_STACK_NAME="devops-infrastructure-stack"   # This is the stack name that the pipeline will create in the test and prod accounts

export DEVOPS_EC2_WEBSERVER_ROLE_NAME="devops-webserver-ec2-role"
export DEVOPS_EC2_WEBSERVER_REPO_NAME="devops-ec2-webserver"
export DEVOPS_EC2_WEBSERVER_PIPELINE_NAME="devops-ec2-webserver-pipeline"

export DEVOPS_S3_WEBSITE_REPO_NAME="devops-s3-website"
export DEVOPS_S3_WEBSITE_PIPELINE_NAME="devops-s3-website-pipeline"
export DEVOPS_S3_WEBSITE_BUILD_PROJECT_NAME="devops-s3-website-build"

# These need to match the values in the infrastructure cloudformation stack:
export WEBSERVER_CODEDEPLOY_APP_NAME="devops-webserver"
export WEBSERVER_CODEDEPLOY_DEPLOYMENT_GROUP_NAME="devops-webserver-deploy-group"


# The values below are derived from the values above and should not be modified:
#-------------------------------------------------------------------------------
export TEST_EC2_WEBSERVER_ROLE_ARN="arn:aws:iam::$TEST_ACCOUNT_ID:role/$DEVOPS_EC2_WEBSERVER_ROLE_NAME"
export PROD_EC2_WEBSERVER_ROLE_ARN="arn:aws:iam::$PROD_ACCOUNT_ID:role/$DEVOPS_EC2_WEBSERVER_ROLE_NAME"

export TEST_WEBSITE_BUCKET_NAME="${TEST_ACCOUNT_ID}-devops-demo-website-test"
export PROD_WEBSITE_BUCKET_NAME="${PROD_ACCOUNT_ID}-devops-demo-website-prod"
export TEST_WEBSITE_BUCKET_ARN="arn:aws:s3:::${TEST_WEBSITE_BUCKET_NAME}"
export PROD_WEBSITE_BUCKET_ARN="arn:aws:s3:::${PROD_WEBSITE_BUCKET_NAME}"