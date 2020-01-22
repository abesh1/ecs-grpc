#!/usr/bin/env bash

export $(cat .env | grep -v ^# | xargs)

if [ -z $PROJECT_NAME ]; then
    echo "PROJECT_NAME environment variable is not set."
    exit 1
fi

if [ -z $AWS_ACCOUNT_ID ]; then
    echo "AWS_ACCOUNT_ID environment variable is not set."
    exit 1
fi

if [ -z $TF_VAR_region ]; then
    echo "AWS_DEFAULT_REGION environment variable is not set."
    exit 1
fi

if [ -z $ENVOY_IMAGE ]; then
    echo "ENVOY_IMAGE environment variable is not set to App Mesh Envoy, see https://docs.aws.amazon.com/app-mesh/latest/userguide/envoy.html"
    exit 1
fi

if [ -z $KEY_PAIR ]; then
    echo "KEY_PAIR environment variable is not set. This must be the name of an SSH key pair, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html"
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ECR_IMAGE_PREFIX=${AWS_ACCOUNT_ID}.dkr.ecr.${TF_VAR_region}.amazonaws.com/${PROJECT_NAME}

deploy_images() {
    echo "Deploying Color Client and Color Server images to ECR..."
    for app in color_client color_server; do
        aws ecr describe-repositories --repository-name ${PROJECT_NAME}/${app} >/dev/null 2>&1 || aws ecr create-repository --repository-name ${PROJECT_NAME}/${app}
        docker build -t ${ECR_IMAGE_PREFIX}/${app} ${DIR}/${app} --build-arg GO_PROXY=${GO_PROXY:-"https://proxy.golang.org"}
        $(aws ecr get-login --no-include-email)
        docker push ${ECR_IMAGE_PREFIX}/${app}
    done
}

deploy_stacks() {
    deploy_images
}

delete_images() {
    for app in color_client color_server; do
        echo "deleting repository \"${app}\"..."
        aws ecr delete-repository \
           --repository-name $PROJECT_NAME/$app \
           --force
    done
}

delete_stacks() {
    delete_images
    echo "all resources from this tutorial have been removed"
}

action=${1:-"deploy"}
if [ "$action" == "delete" ]; then
    delete_stacks
    exit 0
fi

deploy_stacks