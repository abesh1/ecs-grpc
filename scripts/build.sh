#! /bin/bash

SERVICE_NAME=$1

# build image and attach tag
bazelisk --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 build //services/${SERVICE_NAME}:${SERVICE_NAME}_image.tar
docker load -i bazel-bin/services/${SERVICE_NAME}/${SERVICE_NAME}_image.tar
docker tag bazel/services/${SERVICE_NAME}:${SERVICE_NAME}_image 151440741398.dkr.ecr.us-west-2.amazonaws.com/howto-grpc/${SERVICE_NAME}:latest