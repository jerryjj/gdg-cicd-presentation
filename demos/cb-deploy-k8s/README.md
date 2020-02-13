# GKE trigger demo

Configure your environment as in the `setup/README.md`.

## Configure the repo

```sh
rm -fR .git
git init

git remote add google \
https://source.developers.google.com/p/$BUILD_PROJECT_ID/r/cb-deploy-k8s

git add .
```

## Build test image

```sh
gcloud builds submit . \
--project $BUILD_PROJECT_ID \
--tag eu.gcr.io/$BUILD_PROJECT_ID/k8s-demo
```

## Test deployment

```sh
CONTAINER_TAG=$(gcloud --project $BUILD_PROJECT_ID container images list-tags eu.gcr.io/$BUILD_PROJECT_ID/k8s-demo --format="value(tags)" | head -n 1)

cp k8s/deployment.yaml.tpl k8s/deployment.yaml
sed -i "" -e s/BUILD_PROJECT_ID/$BUILD_PROJECT_ID/ k8s/deployment.yaml
sed -i "" -e s/CONTAINER_TAG/$CONTAINER_TAG/ k8s/deployment.yaml

export CONTEXT=`kubectl config view | awk '{print $2}' | grep "demo-cluster" | tail -n 1`

kubectl --context $CONTEXT -n default apply -f k8s/service.yaml
kubectl --context $CONTEXT -n default apply -f k8s/deployment.yaml
```

## Create the Cloud Build trigger

```sh
gcloud beta builds triggers create cloud-source-repositories \
--description "Deploy on any branch" \
--project $BUILD_PROJECT_ID \
--repo=cb-deploy-k8s \
--branch-pattern=".*" \
--substitutions _K8S_ZONE=$COMPUTE_ZONE,_DEPLOY_PROJECT=$DEPLOY_PROJECT_ID \
--build-config=cloudbuild.yaml
```

## Test build

```sh
git commit -a -m "initial commit"
git push google master
```
