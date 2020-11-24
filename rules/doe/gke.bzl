load("@io_bazel_rules_k8s//k8s:object.bzl", "k8s_object")
load("@brezel_defaults//:gcp.bzl", "CLUSTER")
load(":doe.bzl", "doe_k8s_yaml")

def doe_gke(name, visibility=None, **kwargs):
    """Run Design of Experiments on Google Kubernetes Engine."""

    # Variable with the name of the main image running the job.
    # The name can be provided as attibute of this rule using one
    # of the following three options:
    # 1. 'image = "NAME"'
    # 2. 'image = {"NAME": "IMG_LABEL"}'
    # 3. 'images = {"NAME": "IMG_LABEL"}'
    doe_image = None

    # Variable with the optional images attribute passed to rule k8s_object.
    # Populated either by passing the 'images' dictionary directly
    # to this rule, or by passing a dictionary instead of a string in
    # the 'image' attribute.
    k8s_images = {}

    # Forbid mixed usage of attribute 'image' and 'images'
    if "image" in kwargs and "images" in kwargs:
        fail("Attributes 'image' and 'images' can't be specified at the same time.")

    # Set 'doe_image' and 'k8s_images'
    #
    if "images" in kwargs:
        k8s_images = kwargs["images"]
        doe_image = k8s_images.keys()[0]
    elif "image" in kwargs and kwargs["image"]:
        if type(kwargs["image"]) == 'dict':
            k8s_images = kwargs["image"]
            doe_image = k8s_images.keys()[0]
        elif type(kwargs["image"]) == 'string':
            doe_image = kwargs["image"]
        else:
            fail("Invalid type for attriute 'image': expected string or dict")

    # Clean attributes forwarded to 'doe_k8s_yaml'
    attrs = dict(**kwargs)
    attrs.pop("image", default=None)
    attrs.pop("images", default=None)
    experiment = attrs.pop("experiment", default=name)

    # Generate yaml with the kubernetes job description
    doe_k8s_yaml(
        name = name + "-k8s",
        experiment = experiment,
        image = doe_image,
        **attrs,
    )

    # Leave the hard work to `k8s_object`
    k8s_object(
        name = name,
        kind = "job",
        template = ":%s-k8s" % name,
        visibility = visibility,
        images = k8s_images,
        cluster = CLUSTER,
    )
