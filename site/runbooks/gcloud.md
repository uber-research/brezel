## Getting ready to use GCP/gcloud

### Install the SDK
To use Google Cloud based services such as the Docker Registry, Storage or more, you first need to install `gcloud` on your machine.
Please follow the steps describe on [gcloud SDK installation page](https://cloud.google.com/sdk/docs/downloads-interactive), it should have instructions for MacOS, Linux and Windows.

### Install Kubernetes CLI

```
gcloud components install kubectl
```

- [GKE Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart)

### Login
The installation step should include the login procedure. If you still have authentication issues, or if you asked for new permissions that we just given to you may want to run
```bash
gcloud auth login
```

---

### Connect GCP and Docker
To develop and/run projects, you will need to interact with our GCP Docker registries. For this to work you need to run additionally the following command

```
gcloud auth configure-docker
```

### Connect GCP and Kubectl
To interact with the GKE cluster from your local shell, you need to obtain the credentials: (assuming your user account has the appropriate access)

```
gcloud config set project testing
gcloud config set compute/zone europe-west4-b
gcloud container clusters get-credentials cluster
```

Check that it works with `kubectl get nodes`. See the [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) for mode commands to try.

### Upload/Download files to Google Cloud Storage
- [Downloading objects](https://cloud.google.com/storage/docs/downloading-objects)
- [Uploading objects](https://cloud.google.com/storage/docs/uploading-objects)

<br>
