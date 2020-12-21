
#!/bin/bash

# Exit if error occurs:
set -e

# Load configuration values exported from config file:
source config.sh

# In some cases, we will need to retrieve the value of outputs in our 
# CloudFormation stacks. This reusable function lets us do that. 
getCloudFormationStackOutput() {
    local stackName=${1}
    local outputName=${2}
    local profileName=${3}

    aws cloudformation describe-stacks --stack-name $stackName \
        --query "Stacks[0].Outputs[?OutputKey=='${outputName}'].OutputValue" \
        --output text \
        --profile $profileName
}

# Open the specified pipeline template file, replace variable placeholders with their 
# actual environment variable value, then create a pipeline using the parsed template:
createDevOpsPipeline() {
    local templatePath=${1}
    local outputFile="$templatePath.parsed.json"
    envsubst < $templatePath > $outputFile
    aws codepipeline create-pipeline \
        --cli-input-json file://$outputFile \
        --profile $DEVOPS_PROFILE
}

# Create our CodeCommit repositories:
echo $'\nCreating CodeCommit repositories in DevOps account:'
aws cloudformation deploy \
    --stack-name devops-codecommit-repos \
    --template-file lib/devops-account/codecommit-repositories.yaml \
    --profile $DEVOPS_PROFILE \
    --parameter-overrides \
        InfrastructureRepoName=$DEVOPS_INFRASTRUCTURE_REPO_NAME \
        WebServerRepoName=$DEVOPS_EC2_WEBSERVER_REPO_NAME


# Launch cross-account roles in TEST account:
echo $'\nCreating cross-account role (and other deployment resources) in test account:'
aws cloudformation deploy \
    --stack-name $CROSS_ACCOUNT_RESOURCES_STACK_NAME \
    --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $TEST_PROFILE \
    --parameter-overrides \
        DevOpsAccountId=$DEVOPS_ACCOUNT_ID \
        CrossAccountPipelineDeploymentRoleName=$CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_NAME

# Launch cross-account roles in PROD account:
echo $'\nCreating cross-account role (and other deployment resources) in prod account:'
aws cloudformation deploy \
    --stack-name $CROSS_ACCOUNT_RESOURCES_STACK_NAME \
    --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $PROD_PROFILE \
    --parameter-overrides \
        DevOpsAccountId=$DEVOPS_ACCOUNT_ID \
        CrossAccountPipelineDeploymentRoleName=$CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_NAME

# Retrieve resource names created above that we can use as inputs into downstream steps:
export TEST_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CrossAccountPipelineDeploymentRoleArn" "$TEST_PROFILE")
export PROD_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CrossAccountPipelineDeploymentRoleArn" "$PROD_PROFILE")
export TEST_CLOUDFORMATION_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CloudFormationServiceRoleArn" "$TEST_PROFILE")
export PROD_CLOUDFORMATION_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CloudFormationServiceRoleArn" "$PROD_PROFILE")


echo ""
echo $TEST_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN
echo $PROD_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN
echo $TEST_EC2_WEBSERVER_ROLE_ARN
echo $PROD_EC2_WEBSERVER_ROLE_ARN


echo $'\nCreating shared pipeline resources in DevOps account:'
aws cloudformation deploy \
    --stack-name $DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME \
    --template-file lib/devops-account/shared-pipeline-resources.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $DEVOPS_PROFILE \
    --parameter-overrides \
        TestCrossAccountPipelineDeploymentRoleArn=$TEST_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN \
        ProdCrossAccountPipelineDeploymentRoleArn=$PROD_CROSS_ACCOUNT_PIPELINE_DEPLOYMENT_ROLE_ARN \
        TestCrossAccountCloudFormationRoleArn=$TEST_CLOUDFORMATION_ROLE \
        ProdCrossAccountCloudFormationRoleArn=$PROD_CLOUDFORMATION_ROLE \
        InfrastructureRepositoryName=$DEVOPS_INFRASTRUCTURE_REPO_NAME \
        InfrastructurePipelineName=$DEVOPS_INFRASTRUCTURE_PIPELINE_NAME \
        WebserverRepositoryName=$DEVOPS_EC2_WEBSERVER_REPO_NAME \
        WebserverPipelineName=$DEVOPS_EC2_WEBSERVER_PIPELINE_NAME \
        PipelineServiceRoleName=$DEVOPS_PIPELINE_SERVICE_ROLE_NAME \
        PipelineArtifactBucketName=$DEVOPS_CODFEPIPELINE_BUCKET_NAME \
        TestWebServerEC2RoleArn=$TEST_EC2_WEBSERVER_ROLE_ARN \
        ProdWebServerEC2RoleArn=$PROD_EC2_WEBSERVER_ROLE_ARN \
        TestAccountId=$TEST_ACCOUNT_ID \
        ProdAccountId=$PROD_ACCOUNT_ID \
        CodePipelineBranchName=master

# We can't name a KMS key ourselves, so we have to dynamically retrieve its
# ARN after it is created in the stack above: 
export DEVOPS_PIPELINE_KMS_KEY_ARN=$(getCloudFormationStackOutput "$DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME" "PipelineArtifactKmsKeyArn" "$DEVOPS_PROFILE")
export DEVOPS_PIPELINE_SERVICE_ROLE_ARN=$(getCloudFormationStackOutput "$DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME" "CodePipelineServiceRoleArn" "$DEVOPS_PROFILE")

# These commands create our pipeline in the DevOps account. The first command
# loads configuration variables, the second command inserts them into our
# template input and outputs a parsed template file, and the third command
# creates the pipeline from our parsed file.

# CREATE INFRASTRUCTURE PIPELINE
echo $'\nCreating pipeline in DevOps account to launch CloudFormation infrastructure in test/prod accounts:'
createDevOpsPipeline "lib/devops-account/pipeline-definitions/infrastructure-pipeline/pipeline-definition-template.json"

# CREATE WEBSERVER APP PIPELINE
echo $'\nCreating pipeline in DevOps account to build and launch application to EC2 webserver in test/prod accounts:'
createDevOpsPipeline "lib/devops-account/pipeline-definitions/ec2-codedeploy-pipeline/pipeline-definition-template.json"