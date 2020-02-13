# Using Github App Triggers

## Setup

First create a repository to Github `cloud-build-trigger-demo` and set environment

```sh
export REPO_NAME=cloud-build-trigger-demo
export REPO_OWNER=[YOUR_GITHUB_ACCOUNT]
```

### Prepare source folder

```sh
rm -fR .git
git init
git remote add origin git@github.com:$REPO_OWNER/$REPO_NAME.git
git add .
git commit -a -m "initial commit"
git push origin master
```

### Connect Cloud Build to Github

1. Open [Open the Troggers page](https://console.cloud.google.com/cloud-build/triggers) in your Build project.
2. Click Connect repository.
3. Select GitHub (Cloud Build GitHub app), check the consent checkbox, and click Continue.
4. Click Authorize Google Cloud Build by GoogleCloudBuild.
5. Click Install Google Cloud Build.

### Create Trigger

```sh
gcloud beta builds triggers create github \
--description "Github deploy on any PR" \
--project $BUILD_PROJECT_ID \
--substitutions _K8S_ZONE=$COMPUTE_ZONE,_DEPLOY_PROJECT=$DEPLOY_PROJECT_ID \
--build-config=cloudbuild.yaml \
--repo-name=$REPO_NAME \
--repo-owner=$REPO_OWNER \
--pull-request-pattern=".*"
```

### Test the trigger

```sh
git checkout -b feat-1
sed -i "" 's/World/AppTrigger/g' src/index.js
git commit src/index.js -m "new message"
git push origin feat-1
```
