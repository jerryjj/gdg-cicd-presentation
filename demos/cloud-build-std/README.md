# Simple Cloud Build demo

Configure your environment as in the `setup/README.md`.

## Build using only Dockerfile

```sh
gcloud builds submit . \
--project $BUILD_PROJECT_ID \
--tag eu.gcr.io/$BUILD_PROJECT_ID/cloud-build-std
```

## Build using simple Cloudbuild

```sh
gcloud builds submit --config cloudbuild-simple.yaml \
--project $BUILD_PROJECT_ID
```

## Review the console

Go to your build projects [Cloud Build Page](https://console.cloud.google.com/cloud-build?_ga=2.66749738.506765808.1581318419-972073550.1545231431)

## Faster build with Kaniko

```sh
gcloud builds submit --config cloudbuild-kaniko.yaml \
--project $BUILD_PROJECT_ID
```
