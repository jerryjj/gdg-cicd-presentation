apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deploy
  labels:
    app: demo-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-deploy
  template:
    metadata:
      labels:
        app: demo-deploy
    spec:
      containers:
      - name: service
        image: eu.gcr.io/BUILD_PROJECT_ID/k8s-demo:CONTAINER_TAG
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
          name: http
