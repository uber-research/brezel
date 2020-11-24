load(":gke_vars.bzl", "NODEPOOLS", "TAINTS")
load(":config_factory.bzl", "DoeConfigInfo", "stringify_value")

def _to_coma_separated_string(array):
    return ",".join(['"{}"'.format(w) for w in list(array)])

def _ensure_is_abspath(path, attr=None):
    if len(path) > 0 and not path.startswith('/'):
        fail("Only absolute path are accepted: '%s' is invalid." % path, attr)
    pass

def _ensure_is_gcspath(path, attr=None):
    if len(path) > 0 and not path.startswith('gs://'):
        fail("Only gs:// urls are accepted: '%s' is invalid." % path, attr)
    pass

def k8s_jobname(jobgroup, exp, naming):
    use_params = [k for k, v in naming.items() if v != ""]
    jobname = jobgroup + '-' + "-".join([
        stringify_value(exp[p]).replace(',', '')
        for p in use_params
    ])
    return jobname[:63].rstrip('-')

def _doe_jobs(ctx):
    if ctx.attr.config:
        if ctx.attr.matrix or ctx.attr.jobs:
            fail("Cannot mix attribute 'config' with 'matrix' or 'jobs'.")

        jgrp = ctx.attr.experiment if len(ctx.attr.experiment) > 0 else ctx.label.name
        jobgroup = jgrp.replace('_', '-')
        doe_info = ctx.attr.config[DoeConfigInfo]

        mat = ctx.actions.declare_file(ctx.label.name+".mat")
        ctx.actions.write(mat, "\n".join([f.short_path for f in doe_info.files]))
        return mat, [k8s_jobname(jobgroup, exp, doe_info.naming) for exp in doe_info.exps]

    if ctx.attr.matrix and ctx.attr.jobs:
        fail("Cannot mix attributes 'matrix' and 'jobs'. Use attribute 'jobnames' if you just want to specify the names of jobs defined in the matrix.")
    elif ctx.attr.matrix:
        return ctx.file.matrix, ctx.attr.jobnames
    elif ctx.attr.jobs:
        mat = ctx.actions.declare_file(ctx.label.name+".mat")
        ctx.actions.write(mat, "\n".join(ctx.attr.jobs.values()))
        return mat, ctx.attr.jobs.keys()
    else:
        fail("The list of the jobs must be provided. Either with 'matrix' or 'jobs'.")


def _doe_k8s_yaml_impl(ctx):
    exp = ctx.attr.experiment
    tpl = ctx.file._template
    out = ctx.outputs.yaml
    mat, jobnames = _doe_jobs(ctx)
    j2tpl = ctx.actions.declare_file(ctx.label.name+".j2")
    renderer = ctx.executable._renderer

    taint_keys = []
    taint_values = []

    if len(ctx.attr.nodepool) > 0 and ctx.attr.nodepool in TAINTS:
        taints = [taint.split(':') for taint in TAINTS[ctx.attr.nodepool]]
        taint_keys = [t[0] for t in taints]
        taint_values = [t[1] for t in taints]

    # determine cpu request
    cpu = ctx.attr.requests.get('cpu', default=0)
    if ctx.attr.exclusive:
        if ctx.attr.nodepool.rfind('pool-compute-optimized-') < 0:
            fail("Option 'exclusive' can only be used with compute-optimized nodepools")
        cpu = int(ctx.attr.nodepool.replace('pool-compute-optimized-', '')) - 1

    # determine upload map (output_dir -> output_gcs)
    if ctx.attr.output:
        print('Attribute "output" is DEPRECATED. Please use "gcs_upload" instead.')
        output_dir = ctx.attr.output
    if ctx.attr.bucket:
        print('Attribute "bucket" is DEPRECATED. Please use "gcs_upload" instead.')
        output_gcs = ctx.attr.bucket
    if ctx.attr.output and ctx.attr.bucket:
        print('Use intead \'gcs_upload = {"%s": "%s"}\'' % (ctx.attr.output, ctx.attr.bucket))
    if ctx.attr.output and ctx.attr.gcs_upload:
        fail("Cannot mix attributes 'output' and 'gcs_upload'", "gcs_upload")
    if ctx.attr.bucket and ctx.attr.gcs_upload:
        fail("Cannot mix attributes 'bucket' and 'gcs_upload'", "gcs_upload")
    if not ctx.attr.gcs_upload and (not ctx.attr.output or not ctx.attr.bucket):
        fail("GCS upload map must be provided", "gcs_upload")
    if ctx.attr.gcs_upload:
        upload_map = dict(ctx.attr.gcs_upload)
        if len(upload_map) > 1:
            fail("Only one directory mapping is currently supported.")
        output_dir, output_gcs = upload_map.popitem()

    _ensure_is_abspath(output_dir)
    _ensure_is_gcspath(output_gcs)

    # determine download map (input_gcs -> input_dir)
    input_dir = ""
    input_gcs = ""
    if ctx.attr.gcs_download:
        download_map = dict(ctx.attr.gcs_download)
        if len(download_map) > 1:
            fail("Only one directory mapping is currently supported.")
        input_gcs, input_dir = download_map.popitem()

    _ensure_is_abspath(input_dir)
    _ensure_is_gcspath(input_gcs)
    if input_gcs.endswith('/'):
        input_gcs = input_gcs + "**"

    n_gpus = {
        'pool-gpu': '1',
        'pool-gpu-highmem': '1',
        'pool-gpu-beefy': '8'
    }.get(ctx.attr.nodepool, '0')

    # Prepare jinja2 template
    substitutions = {
        "{JOBNAME}": exp if len(exp) > 0 else ctx.label.name,
        "{JOBGROUP}": exp if len(exp) > 0 else ctx.label.name,
        "{JOBNAMES}": _to_coma_separated_string(jobnames),
        "{JOBDEADLINE}": str(ctx.attr.deadline),
        "{INPUT_GCS}": input_gcs,
        "{INPUT_DIR}": input_dir,
        "{OUTPUT_GCS}": output_gcs,
        "{OUTPUT_DIR}": output_dir,
        "{COMMAND}": ctx.attr.command,
        "{IMAGE}": ctx.attr.image,
        "{REQUEST_CPU}": "{}".format(cpu),
        "{REQUEST_MEM}": ctx.attr.requests.get('memory', '0'),
        "{NODEPOOL}": ctx.attr.nodepool,
        "{N_GPUS}": n_gpus,
        "{TOLERATION_KEYS}": _to_coma_separated_string(taint_keys),
        "{TOLERATION_VALUES}": _to_coma_separated_string(taint_values),
        "{COMPRESS}": "true" if ctx.attr.compress else "false",
    }

    ctx.actions.expand_template(
        template = tpl,
        output = j2tpl,
        substitutions = substitutions
    )

    # Render template
    ctx.actions.run(
        outputs = [out],
        inputs = [j2tpl, mat],
        executable = renderer,
        arguments = [j2tpl.path, mat.path, out.path],
    )


doe_k8s_yaml = rule(
    implementation = _doe_k8s_yaml_impl,
    attrs = {
        "_renderer": attr.label(
            default = Label("@brezel//rules/doe:jinja2_renderer"),
            executable = True,
            cfg = "host",
        ),
        "_template": attr.label(
            default = Label("@brezel//rules/doe:templates/k8s-job.yaml.j2"),
            allow_single_file = True,
        ),
        "image": attr.string(mandatory=True),
        "experiment": attr.string(),
        "command": attr.string(),
        "output": attr.string(doc="DEPRECATED. Use gcs_upload instead."),
        "bucket": attr.string(doc="DEPRECATED. Use gcs_upload instead."),
        "jobs": attr.string_dict(),
        "matrix": attr.label(allow_single_file=True),
        "config": attr.label(allow_files=True, providers=[DoeConfigInfo]),
        "deadline": attr.int(default=-1),
        "nodepool": attr.string(values=['']+NODEPOOLS),
        "exclusive": attr.bool(),
        "requests": attr.string_dict(),
        "gcs_upload": attr.string_dict(),
        "gcs_download": attr.string_dict(),
        "compress": attr.bool(default=True),
        "jobnames": attr.string_list(),
    },
    outputs = {"yaml": "%{name}.yaml"},
    doc = "Generate YAML for Kubernetes",
)
