#!/bin/bash

## display help
if [ "$1" == "--help" ]; then
	echo "usage: ./build.sh [optional 1st arg: docker image tag | default: latest] [optional 2nd arg: environment | PROD or QA"
	exit 0
fi

## import $DOCKER_IMAGE from .env
DOCKER_IMAGE=$(grep DOCKER_IMAGE ./.env | xargs)
DOCKER_IMAGE=${DOCKER_IMAGE#*=}
DOCKER_ACCOUNT=$(grep DOCKER_ACCOUNT ./.env | xargs)
DOCKER_ACCOUNT=${DOCKER_ACCOUNT#*=}
NAMESPACE_QA=$(grep NAMESPACE_QA ./.env | xargs)
NAMESPACE_QA=${NAMESPACE_QA#*=}
NAMESPACE_PROD=$(grep NAMESPACE_PROD ./.env | xargs)
NAMESPACE_PROD=${NAMESPACE_PROD#*=}

## check for required .env variables
if [ -z "$DOCKER_IMAGE" ]; then
    echo "DOCKER_IMAGE env variable is required to be declared in .env"
    exit 1
fi

if [ -z "$DOCKER_ACCOUNT" ]; then
    echo "DOCKER_ACCOUNT env variable is required to be declared in .env"
    exit 1
fi

if [ -z "$NAMESPACE_QA" ]; then
    echo "NAMESPACE_QA env variable is required to be declared in .env"
    exit 1
fi

if [ -z "$NAMESPACE_PROD" ]; then
    echo "NAMESPACE_PROD env variable is required to be declared in .env"
    exit 1
fi

## let the magic begin
TAG=latest
NAMESPACE=""
CONTAINER=$DOCKER_ACCOUNT/$DOCKER_IMAGE

if [ ! -z "$1" ]; then
    TAG=$1
fi

if [ ! -z "$2" ]; then
	if [ "$2" == "QA" ]; then
    	NAMESPACE=$NAMESPACE_QA
    fi

	if [ "$2" == "PROD" ]; then
    	NAMESPACE=$NAMESPACE_PROD
    fi
fi

## build and push docker image
echo "Building Docker image: [ $CONTAINER:$TAG ]"
docker build -t $CONTAINER:$TAG . && \
docker push     $CONTAINER:$TAG   && \

## update Kubernetes deployment only if env is provided as a second argument
echo "Updating Kubernetes deployment: [ $DOCKER_IMAGE ] on [ $NAMESPACE ] namespace"
if [ "$NAMESPACE" != "" ]; then
	kubectl patch deployment $DOCKER_IMAGE -n $NAMESPACE -p \
		"{\"spec\": {\"template\": {\"metadata\": {\"annotations\": {\"date\":\"`date +'%s'`\"}}, \"spec\": {\"initContainers\": [{\"name\": \"app\",\"image\": \"index.docker.io/$CONTAINER:$TAG\"}]}}}}"
fi
