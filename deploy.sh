
#!/bin/bash -e

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

createDevOpsPipeline "lib/devops-account/pipeline-definitions/infrastructure-pipeline/pipeline-definition-template.json"

exit;

# Create our CodeCommit repositories:
aws cloudformation deploy \
    --stack-name devops-codecommit-repos \
    --template-file lib/devops-account/codecommit-repositories.yaml \
    --profile $DEVOPS_PROFILE \
    --parameter-overrides \
        InfrastructureRepoName=$DEVOPS_INFRASTRUCTURE_REPO_NAME


# Launch cross-account roles in TEST account:
aws cloudformation deploy \
    --stack-name crossaccount-deployment-roles \
    --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $TEST_PROFILE \
    --parameter-overrides \
        DevOpsAccountId=$DEVOPS_ACCOUNT_ID

# Launch cross-account roles in PROD account:
aws cloudformation deploy \
    --stack-name crossaccount-deployment-roles \
    --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $PROD_PROFILE \
    --parameter-overrides \
        DevOpsAccountId=$DEVOPS_ACCOUNT_ID

# Retrieve resource names created above that we can feed into downstream steps:
export TEST_CROSSACCOUNT_CODEDEPLOY_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CrossAccountCodeDeployRoleArn" "$TEST_PROFILE")
export PROD_CROSSACCOUNT_CODEDEPLOY_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CrossAccountCodeDeployRoleArn" "$PROD_PROFILE")
export TEST_CLOUDFORMATION_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CloudFormationServiceRoleArn" "$TEST_PROFILE")
export PROD_CLOUDFORMATION_ROLE=$(getCloudFormationStackOutput "$CROSS_ACCOUNT_RESOURCES_STACK_NAME" "CloudFormationServiceRoleArn" "$PROD_PROFILE")

# Launch resources needed in DevOps account before we create our DevOps pipelines:
aws cloudformation deploy \
    --stack-name $DEVOPS_SHARED_PIPELINE_RESOURCES_STACK_NAME \
    --template-file lib/devops-account/shared-pipeline-resources.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $DEVOPS_PROFILE \
    --parameter-overrides \
        TestCrossAccountCodeDeployRoleArn=$TEST_CROSSACCOUNT_CODEDEPLOY_ROLE \
        ProdCrossAccountCodeDeployRoleArn=$PROD_CROSSACCOUNT_CODEDEPLOY_ROLE \
        TestCrossAccountCloudFormationRoleArn=$TEST_CLOUDFORMATION_ROLE \
        ProdCrossAccountCloudFormationRoleArn=$PROD_CLOUDFORMATION_ROLE \
        InfrastructureRepositoryName=$DEVOPS_INFRASTRUCTURE_REPO_NAME \
        InfrastructurePipelineName=$DEVOPS_INFRASTRUCTURE_PIPELINE_NAME \
        PipelineServiceRoleName=$DEVOPS_PIPELINE_SERVICE_ROLE_NAME \
        PipelineArtifactBucketName=$DEVOPS_CODFEPIPELINE_BUCKET_NAME \
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
createDevOpsPipeline "lib/devops-account/infrastructure-pipeline/pipeline-definition.json"