# Cloud Build trigger demo

Configure your environment as in the `setup/README.md`.

## Configure the repo

```sh
rm -fR .git
git init

git remote add google \
https://source.developers.google.com/p/$BUILD_PROJECT_ID/r/cb-trigger-demo

git add .
git commit -a -m "initial commit"
```

## Create the Cloud Build trigger

```sh
gcloud beta builds triggers create cloud-source-repositories \
--description "Simple trigger on any branch" \
--project $BUILD_PROJECT_ID \
--repo=cb-trigger-demo \
--branch-pattern=".*" \
--build-config=cloudbuild.yaml
```

## Test build

```sh
git commit -a -m "initial commit"
git push google master
```

## Run build with Container cache

```sh
gcloud beta builds triggers create cloud-source-repositories \
--description "Trigger on any branch with Cache" \
--project $BUILD_PROJECT_ID \
--repo=cb-trigger-demo \
--branch-pattern=".*" \
--build-config=cloudbuild-cache.yaml
```

## Test cached build

```sh
git add cloudbuild-cache.yaml
git commit cloudbuild-cache.yaml -m "added cached cloudbuild"
git push google master
```
