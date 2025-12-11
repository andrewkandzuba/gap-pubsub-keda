# dt-producer

This application produces simple JSON messages to a Google Pub/Sub topic.

## Prerequisites

-   [gcloud CLI](https://cloud.google.com/sdk/docs/install)
-   [Docker](https://docs.docker.com/get-docker/)
-   [Helm](https://helm.sh/docs/intro/install/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Build

1.  **Navigate to the `dt-producer` directory:**

    ```bash
    cd dt-producer
    ```

2.  **Set your GCP Project ID:**

    ```bash
    export PROJECT_ID="your-gcp-project-id"
    ```

3.  **Build the Docker image:**

    ```bash
    docker build -t "gcr.io/${PROJECT_ID}/dt-producer:latest" .
    ```

4.  **Configure Docker to use gcloud for authentication:**

    ```bash
    gcloud auth configure-docker
    ```

5.  **Push the Docker image to Google Container Registry (GCR):**

    ```bash
    docker push "gcr.io/${PROJECT_ID}/dt-producer:latest"
    ```

## Deploy

1.  **Update `helm/values.yaml`:**
    *   Set `projectId` to your GCP Project ID.
    *   Set `image.repository` to `gcr.io/${PROJECT_ID}/dt-producer`.

2.  **Navigate to the Helm chart directory:**

    ```bash
    cd helm
    ```

3.  **Install the Helm chart:**

    ```bash
    helm install dt-producer . --namespace producer --create-namespace
    ```

