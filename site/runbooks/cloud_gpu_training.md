### Train Python models on cloud GPUs using Bazel

We use Bazel, Kubernetes and GCP to train machine learning models on cloud GPUs. So before getting started, make sure that:
- You followed [Gcloud's runbook](gcloud.md) until the end.
- You familiarized yourself with Bazel and our monorepo.

The current method relies on Brezel's `doe_gke` rule which is documented [here](cloud_doe.md).
The key is to specify our cluster's GPU nodepool: `pool-gpu` and use the correct base image when packaging your Python training code with Bazel.

For example, here is how to package your code in a Python 3 image:

    py3_image(
        name = "ae_train",
        main = "train.py",
        srcs = ["train.py"],
        deps = DEPS,
        layers = LAYERS,
        base = "@brezel//docker:python3_gpu_gke_base"
    )

Now, create a design of experiments:

    doe_gke(
        name = "ae-gke",
        image = {"eu.gcr.io/testing/some-image": ":ae_train"},
        gcs_upload = {"/tmp/results": "gs://data/experiments/some_folder"},
        matrix = ":experiments.mat",
        nodepool = "pool-gpu"
    )

```eval_rst
.. important:: Once your job is running, you can use `kubectl get pods` to get your pod name and inspect the log of your job using `kubectl logs [pod_name] -c worker -f`. You can also redirect Tensorboard to your localhost using:
```

#### Monitoring with Tensorboard
In the example above, Tensorboard is instantiated from the python training script. To be able to use it for a job running on the cloud, get the pod name using `kubectl get pods` and use `port-forward` to access Tensorboard on the localhost.


    kubectl port-forward [pod_name] 6006:6006

<br>
