# Cloud Build trigger demo

Configure your environment as in the `setup/README.md`.

## Configure the repo

```sh
rm -fR .git
git init

git remote add google \
https://source.developers.google.com/p/$BUILD_PROJECT_ID/r/cb-deploy-run

git add .
```

## Build test image

```sh
gcloud builds submit . \
--project $BUILD_PROJECT_ID \
--tag eu.gcr.io/$BUILD_PROJECT_ID/run-demo
```

## Test Cloud Run deployment

```sh
gcloud run deploy deploy-demo \
--project $DEPLOY_PROJECT_ID \
--image eu.gcr.io/$BUILD_PROJECT_ID/run-demo \
--region europe-north1 \
--platform managed \
--allow-unauthenticated
```

## Create the Cloud Build trigger

```sh
gcloud beta builds triggers create cloud-source-repositories \
--description "Deploy on any branch" \
--project $BUILD_PROJECT_ID \
--repo=cb-deploy-run \
--branch-pattern=".*" \
--substitutions _RUN_REGION=$COMPUTE_REGION,_DEPLOY_PROJECT=$DEPLOY_PROJECT_ID \
--build-config=cloudbuild.yaml
```

## Test build

```sh
git commit -a -m "initial commit"
git push google master
```
