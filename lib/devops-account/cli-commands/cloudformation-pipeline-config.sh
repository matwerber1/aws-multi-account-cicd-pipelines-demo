# This file will be used by the gettext tool to substitute 
# placeholders in example files with the parameters below:

# IAM role in DevOps account assumed by CodePipeline to orchestrate CICD tasks:
export DEVOPS_PIPELINE_ROLE_ARN="arn:aws:iam::111111111111:role/devops-codepipeline-service-role"

# Bucket name in DevOps account used to store pipeline artifacts:
export DEVOPS_CODFEPIPELINE_BUCKET_NAME="111111111111-codepipeline-devops-artifacts"

# KMS key in DevOps account used by CodePipeline in DevOps account to encrypt artifacts stored in the pipeline bucket:
export DEVOPS_PIPELINE_KMS_KEY_ARN="arn:aws:kms:us-west-2:111111111111:key/a1983de2-ea56-4255-a7ae-489dfa444f0a"

# CodeCommit repo in DevOps account containing infrastructure source code (i.e. a CloudFormation template):
# If you change this value, you will also need to update the devops CloudFormation stack launched earlier!
export DEVOPS_INFRASTRUCTURE_REPO_NAME="infrastructure-pipeline"

# IAM role in DevOps account assumed by CodeCommit source action in CodePipeline to pull code: 
#export DEVOPS_PIPELINE_CODECOMMIT_ROLE="arn:aws:iam::255629334033:role/DevOpsStack-FrontEndInfraPipelineSourceCodeCommitS-1Q8ZSNZH9KMTU"

# IAM role in test and prod account that CodeDeploy assumes to execute deployment actions in the other account: 
export TEST_CROSSACCOUNT_CODEDEPLOY_ROLE="arn:aws:iam::222222222222:role/devops-crossaccount-codedeploy-role"
export PROD_CROSSACCOUNT_CODEDEPLOY_ROLE="arn:aws:iam::333333333333:role/devops-crossaccount-codedeploy-role"

# IAM role in Test and Prod accounts that the account's CodeDeploy role will pass to CloudFormation to execute stack deployment: 
export TEST_CLOUDFORMATION_ROLE="arn:aws:iam::222222222222:role/devops-cloudformation-service-role"
export PROD_CLOUDFORMATION_ROLE="arn:aws:iam::333333333333:role/devops-cloudformation-service-role"

# The name of the infrastructure CloudFormation stack that DevOps pipeline will create in test and prod accounts:
export INFRASTRUCTURE_CLOUDFORMATION_STACK_NAME="devops-infrastructure-stack"