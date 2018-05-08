# Kubernetes Deployment Patch
Simple single bash command script to:

1. build a tagged Docker image
2. push it into Docker repository
3. force Kubernetes rolling deployment within selected namespace

## Assumptions
Docker image name is the same as Kubernetes deployment name.

## Installation
1. Copy `build.sh` into your executable environment $PATH.

*example:*
```
cp ./build.sh /usr/local/bin/build
```

2. Add required environment variables listed in `.env` file into your project `.env` where Dockerfile is located

*example:*
```
cat ./env >> /path_to_your_project_where_Dockerfile_is_located/.env
```

## Usage
```
build --help
```

*examples:*

build Docker image tagged as latest & push it into Docker repository:
```
build 
```

build image tagged 1.0.0, push it into Docker repository and patch Kubernetes deployment to use it in production namespace:
```
build 1.0.0 PROD
```

