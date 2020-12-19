
#!/bin/bash -e

TEST_PROFILE="ctt-test"
PROD_PROFILE="ctt-prod"
DEVOPS_PROFILE="ctt-team-1"

DEVOPS_ACCOUNT_ID="255629334033"

# Launch cross-account roles in TEST account:
aws cloudformation deploy \
    --stack-name crossaccount-deployment-roles \
    --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $TEST_PROFILE \
    --parameter-overrides \
        DevOpsAccountId=$DEVOPS_ACCOUNT_ID

# Launch resources needed in DevOps account before we create our DevOps pipelines:
aws cloudformation deploy \
    --stack-name devops-pipeline-resources \
    --template-file lib/devops-account/cloudformation/cf-devops-pipeline-resources-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $DEVOPS_PROFILE \
    --parameter-overrides \
        TestCrossAccountCodeDeployRoleArn=arn:aws:iam::723403234461:role/devops-crossaccount-codedeploy-role \
        ProdCrossAccountCodeDeployRoleArn=arn:aws:iam::723403234461:role/devops-crossaccount-codedeploy-role \
        TestCrossAccountCloudFormationRoleArn=arn:aws:iam::723403234461:role/devops-cloudformation-service-role \
        ProdCrossAccountCloudFormationRoleArn=arn:aws:iam::723403234461:role/devops-cloudformation-service-role \
        CodeCommitRepositoryName=infrastructure-pipeline \
        CodePipelineName=infrastructure_pipeline \
        CodePipelineBranchName=master


# These commands create our pipeline in the DevOps account. The first command
# loads configuration variables, the second command inserts them into our
# template input and outputs a parsed template file, and the third command
# creates the pipeline from our parsed file:
source lib/devops-account/cli-commands/cloudformation-pipeline-config.sh
envsubst < lib/devops-account/cli-commands/cloudformation-pipeline-template.json > lib/devops-account/cli-commands/cloudformation-pipeline-parsed.json
aws codepipeline create-pipeline \
    --cli-input-json file://lib/devops-account/cli-commands/cloudformation-pipeline-parsed.json \
    --profile $DEVOPS_PROFILE