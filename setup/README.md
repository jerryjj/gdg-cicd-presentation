# Setup

Prepare the environment variables:

```sh
source env-setup
```

Set following required env values aswell

```sh
export ORGANIZATION_ID=[YOUR ORG ID]
export BILLING_ID=[YOUR_BILLING_ID]
```

## GCP

### Creating projects

```sh
gcloud projects create $DEPLOY_PROJECT_ID
gcloud projects create $BUILD_PROJECT_ID
```

### Attach billing to these projects

```sh
gcloud --quiet beta billing projects link $DEPLOY_PROJECT_ID --billing-account $BILLING_ID
gcloud --quiet beta billing projects link $BUILD_PROJECT_ID --billing-account $BILLING_ID
```

### Enable required APIs in the projects

#### Deploy project

```sh
ENABLE_APIS=(
"cloudresourcemanager.googleapis.com" \
"compute.googleapis.com" \
"container.googleapis.com" \
"run.googleapis.com" \
"storage-api.googleapis.com" \
"servicenetworking.googleapis.com" \
"monitoring"
)

gcloud services enable --project=$DEPLOY_PROJECT_ID ${ENABLE_APIS[@]}
```

#### Build project

```sh
ENABLE_APIS=(
"cloudresourcemanager.googleapis.com" \
"servicemanagement.googleapis.com" \
"sourcerepo.googleapis.com" \
"storage-api.googleapis.com" \
"cloudbuild.googleapis.com" \
"container.googleapis.com" \
"containerregistry.googleapis.com" \
"containeranalysis.googleapis.com" \
"run.googleapis.com" \
"monitoring"
)

gcloud services enable --project=$BUILD_PROJECT_ID ${ENABLE_APIS[@]}
```

### Prepare the Deploy -project

#### Create Kubernetes Cluster

```sh
gcloud beta container clusters create "demo-cluster" \
--project $DEPLOY_PROJECT_ID \
--zone $COMPUTE_ZONE \
--release-channel "stable" \
--machine-type "n1-standard-1" --image-type "COS" \
--disk-type "pd-standard" --disk-size "100" \
--metadata disable-legacy-endpoints=true \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--num-nodes "3" \
--default-max-pods-per-node "110" \
--no-enable-basic-auth \
--no-issue-client-certificate \
--enable-stackdriver-kubernetes \
--enable-ip-alias \
--network "projects/$DEPLOY_PROJECT_ID/global/networks/default" \
--subnetwork "projects/$DEPLOY_PROJECT_ID/regions/$COMPUTE_REGION/subnetworks/default" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
--istio-config=auth=MTLS_PERMISSIVE \
--enable-autoupgrade --enable-autorepair \
--no-shielded-integrity-monitoring
```

Get Context

```sh
export CONTEXT=`kubectl config view | awk '{print $2}' | grep "demo-cluster" | tail -n 1`
```

Set yourself as the cluster admin

```sh
ACCOUNT=$(gcloud info --format='value(config.account)')
NAME=$(echo "${ACCOUNT%@*}")
kubectl --context $CONTEXT create clusterrolebinding $NAME-cluster-admin-binding \
--clusterrole=cluster-admin --user=$ACCOUNT
```

Configure default namespace to auto-inject Istio sidecars

```sh
kubectl --context $CONTEXT label namespace default istio-injection=enabled
```

### Prepare the Build -project

#### Prepare source repos

Install the Git credential helper tool

```sh
git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
```

Create a repos for demos

```sh
gcloud source repos create cb-trigger-demo \
--project $BUILD_PROJECT_ID

gcloud source repos create cb-deploy-run \
--project $BUILD_PROJECT_ID

gcloud source repos create cb-deploy-k8s \
--project $BUILD_PROJECT_ID
```

#### Prepare GCR & Allow Cluster and Cloud Run to fetch containers

```sh
DEPLOY_PROJECT_NUMBER=$(gcloud projects describe $DEPLOY_PROJECT_ID --format='value(projectNumber)')
GKE_SA_EMAIL="$DEPLOY_PROJECT_NUMBER-compute@developer.gserviceaccount.com"
RUN_SA_EMAIL="service-$DEPLOY_PROJECT_NUMBER@serverless-robot-prod.iam.gserviceaccount.com"
BUCKET_PATH="gs://eu.artifacts.$BUILD_PROJECT_ID.appspot.com"

gcloud container images add-tag \
--project $BUILD_PROJECT_ID \
gcr.io/google-samples/hello-app:1.0 \
eu.gcr.io/$BUILD_PROJECT_ID/hello-app:1.0 \
--quiet

gcloud container images delete eu.gcr.io/$BUILD_PROJECT_ID/hello-app:1.0 \
--project $BUILD_PROJECT_ID --quiet

gsutil iam ch serviceAccount:$GKE_SA_EMAIL:objectViewer $BUCKET_PATH
gsutil iam ch serviceAccount:$RUN_SA_EMAIL:objectViewer $BUCKET_PATH
```

#### Allow Cloud Build to deploy to Cloud Run

```sh
BUILD_PROJECT_NUMBER=$(gcloud projects describe $BUILD_PROJECT_ID --format='value(projectNumber)')
CB_SA_EMAIL="$BUILD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com"
DEPLOY_PROJECT_NUMBER=$(gcloud projects describe $DEPLOY_PROJECT_ID --format='value(projectNumber)')
COMPUTE_SA_EMAIL="$DEPLOY_PROJECT_NUMBER-compute@developer.gserviceaccount.com"

gcloud projects add-iam-policy-binding $DEPLOY_PROJECT_ID \
--member=serviceAccount:$CB_SA_EMAIL \
--role roles/run.admin

gcloud iam service-accounts add-iam-policy-binding \
$COMPUTE_SA_EMAIL \
--project $DEPLOY_PROJECT_ID \
--member="serviceAccount:$CB_SA_EMAIL" --role=roles/iam.serviceAccountUser
```

#### Allow Cloud Build to deploy to Kubernetes

```sh
BUILD_PROJECT_NUMBER=$(gcloud projects describe $BUILD_PROJECT_ID --format='value(projectNumber)')
CB_SA_EMAIL="$BUILD_PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $DEPLOY_PROJECT_ID \
--member=serviceAccount:$CB_SA_EMAIL \
--role roles/container.developer
```
