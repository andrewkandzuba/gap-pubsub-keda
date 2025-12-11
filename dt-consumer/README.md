# dt-consumer

This application consumes simple JSON messages from a Google Pub/Sub topic and is scaled by a Horizontal Pod Autoscaler (HPA) based on the number of undelivered messages.

## Prerequisites

-   [gcloud CLI](https://cloud.google.com/sdk/docs/install)
-   [Docker](https://docs.docker.com/get-docker/)
-   [Helm](https://helm.sh/docs/intro/install/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Build

1.  **Navigate to the `dt-consumer` directory:**

    ```bash
    cd dt-consumer
    ```

2.  **Set your GCP Project ID:**

    ```bash
    export PROJECT_ID="your-gcp-project-id"
    ```

3.  **Build the Docker image:**

    ```bash
    docker build -t "gcr.io/${PROJECT_ID}/dt-consumer:latest" .
    ```

4.  **Configure Docker to use gcloud for authentication:**

    ```bash
    gcloud auth configure-docker
    ```

5.  **Push the Docker image to Google Container Registry (GCR):**

    ```bash
    docker push "gcr.io/${PROJECT_ID}/dt-consumer:latest"
    ```

## Deploy

1.  **Update `helm/values.yaml`:**
    *   Set `projectId` to your GCP Project ID.
    *   Set `image.repository` to `gcr.io/${PROJECT_ID}/dt-consumer`.

2.  **Navigate to the Helm chart directory:**

    ```bash
    cd helm
    ```

3.  **Install the Helm chart:**

    ```bash
    helm install dt-consumer . --namespace consumer --create-namespace
    ```

