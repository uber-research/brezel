How-To: Download input files from GCS bucket
============================================

Objective
---------

The goal of this runbook is to demonstrate the usage of the bazel rule
`gcs_bucket_download`. We will illustrate it with the example of a Machine
Learning training script requiring model data stored in a bucket on Google
Cloud Storage (GCS).

Context
-------

Let's say you have written a training script in python that takes a csv file
containing your input data as first argument. File `training.py` could for
example look like this:

```python
#!/usr/bin/env python
import click
import pandas as pd

@click.command()
@click.argument('csv')
def train(csv):
    data = pd.read_csv(csv, sep=';')
    print(data.head()) 
    # do something meaningful with the data ...

if __name__ == '__main__':
    train()
```

Inside a research project, the following bazel BUILD file could be
added to run `training.py`:
```
load("@python3_deps//:requirements.bzl", "requirement")
load("@python3_extra_deps//:requirements.bzl", extra_requirement="requirement")
load("@rules_python//python:defs.bzl", "py_binary")

py_binary(
    name = "training",
    srcs = ["training.py"],
    deps = [
        requirement('click'),
        extra_requirement('pandas'),
    ],
)
```

If we try `bazel run :training` right now, the script complains about the missing
argument. We can provide it with the `args` attribute of the `py_binary` rule.
As bazel executes the script in a sandbox, we need to make all input files available
there by specifiying the appropriate [data dependencies](https://docs.bazel.build/versions/master/build-ref.html#data).

Declare data files in GCS bucket
--------------------------------

Inside the project `WORKSPACE`, pass the list of the files on GCS you want to
be available:
```
# WORKSPACE
load("@brezel//bazel/gcs:download.bzl", "gcs_bucket_download")
gcs_bucket_download(
    name = "data",
    bucket = "gs://data",
    data_file_list = [
        (
            "example_csv",
            "project/data.csv",
            "7c4dc5d80d81b8eeb76bd8ef1dcb8d0564292de86e76bdee6d32412a3c1708fb"
        ),
    ],
)
```

```eval_rst
.. note:: Only the files that you use inside a BUILD rule will be downloaded from GCS. The other items in `data_file_list` will not be fetched. The effective downloading happens at build time (it means they won't be downloadeed until you build a target depending on them).
```

For each `(file, path, hash)` triplet in `data_file_list`, the following target is created
```
@name//:file
```
with `name` being the value passed to `gcs_bucket_download` (`data` here).

Provide data files in bazel build file
--------------------------------------

```
py_binary( 
    name = "training",
    srcs = ["training.py"],
    data = ["@data//:example_csv"],
    args = ["$(location @data//:example_csv)"],
    deps = [...],
)
```

Note how we obtain the path of the file in the sandbox from its label using
the `$(location)` build-in function.

```eval_rst
.. note:: Alternatively, you can refer to a data file with the relative path **external/<name>/<file>**.
```

For convenience, you group multiple files under a same name using a `filegroup` rule:
```
filegroup(
    name = "training_data",
    srcs = [
        "@data//:training_x",
        "@data//:training_y",
    ],
)
```

Note that if the target contains multiple data files, you need to use `$(locations)`
instead of `$(location)`:
```
    data = [":training_data"],
    args = ["$(locations :training_data)"],
```

Limitations
-----------

Only build inputs can be downloaded with this method. The build remains
deterministic because the hashes of the downloaded files must be provided.

In particular, the rule `gcs_bucket_download` cannot be used for retrieving
generated outputs.

Calling `gcs_bucket_download` is only allowed during the Loading phase and thus
must be written in bazel `WORKSPACE`.

<br>
