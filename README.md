# AWS Multi-Account CI/CD Pipelines

This project demonstrates how to create multi-account CI/CD deployment pipelines using AWS-native services, including CodeCommit, CodePipeline, CodeBuild, CodeDeploy, and more. 

Normally, I would recommend the AWS CDK, rather than writing CloudFormation "by hand" or using the AWS CLI to create certain resources (as I do in this project). However, I wanted to do demonstrate how to do this "by hand" for those not using the CDK. The other reason is that the CDK abstracts a number of aspects, and for my own learning, I like doing things at a lower level for learning purposes. 

## Status

At the moment, this project has a working example of cross-account CI/CD workflows whereby you can define an "infrastructure" CodeCommit repository in a DevOps account that is intended to hold a CloudFormation template (`cloudformation.yaml`). The DevOps account also has an AWS CodePipeline pipeline that is triggered upon commits to the repository and then launches the stack in a test account, waits for manual approval, and then launches the stack in the production account. 

Deployment instructions below are not yet completed... but you can look in `deployment-commands.sh` to see all commands that you need to run in order. 

I will eventually work on automating more aspects of the deployment process, better documentation, and additional CI/CD examples. 

## Deployment

1. Install `gettext` to help with generating example template files. If on MacOS, use `brew install gettext`. 

1. Make sure your local AWS CLI has been configured with a profile for each of your devops, test, and production accounts. Afterward, export the profile names of each account, and your devops account ID, to your local shell, as we will need this later: 

    ```sh
    TEST_PROFILE="testProfile"
    PROD_PROFILE="prodProfile"
    DEVOPS_PROFILE="devOpsProfile"
    DEVOPS_ACCOUNT_ID="111222333444"
    ```

1. Create cross-account IAM roles in your test account by launching the CloudFormation stack below: 

    ```sh
    aws cloudformation deploy \
        --stack-name crossaccount-deployment-roles \
        --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
        --capabilities CAPABILITY_NAMED_IAM \
        --profile $TEST_PROFILE \
        --parameter-overrides \
            DevOpsAccountId=$DEVOPS_ACCOUNT_ID
    ```

1. Create cross-account IAM roles in the prod account, as well:

    ```sh
    aws cloudformation deploy \
        --stack-name crossaccount-deployment-roles \
        --template-file lib/deployment-account/cf-cross-account-iam-roles.yaml \
        --capabilities CAPABILITY_NAMED_IAM \
        --profile $PROD_PROFILE \
        --parameter-overrides \
            DevOpsAccountId=$DEVOPS_ACCOUNT_ID
    ```
