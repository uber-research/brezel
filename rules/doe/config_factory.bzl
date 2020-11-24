DoeParamInfo = provider(fields=["key", "values", "naming"])
DoeConfigInfo = provider(fields=["files", "exps", "naming", "prefix"])


def _doe_config_list_impl(ctx):
    info = ctx.attr.deps[0][DoeConfigInfo]
    ctx.actions.expand_template(
        template = ctx.file._config_list_tpl,
        output = ctx.outputs.executable,
        substitutions = {
            "%{PATHS}": " ".join([f.short_path for f in info.files]),
            "%{PARAMS}": " ".join(["'{}'".format(e) for e in info.exps]),
        },
        is_executable = True,
    )
    return [DefaultInfo(runfiles = ctx.runfiles(files=ctx.files.data))]

_doe_config_list = rule(
    implementation = _doe_config_list_impl,
    executable = True,
    attrs = {
        "_config_list_tpl": attr.label(
            default = "@brezel//rules/doe:tools/config_list.tpl.sh",
            allow_single_file=True,
        ),
        "deps": attr.label_list(
            mandatory = True,
            allow_empty = False,
            providers = [DoeConfigInfo],
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
    },
)


def _doe_config_param_impl(ctx):
    upper_name = ctx.label.name.upper()
    param_key = ctx.attr.key if ctx.attr.key else upper_name

    naming = "%s_{}" % param_key
    # don't use parameter in naming if single value (unless told to)
    if len(ctx.attr.values) <= 1 and ctx.attr.always_contribute_to_naming == False:
        naming = ""
    # but always honor naming if explicitely set
    if ctx.attr.naming:
        naming = ctx.attr.naming

    return [DoeParamInfo(
        key = param_key,
        values = ctx.attr.values,
        naming = naming,
    )]


doe_config_param = rule(
    implementation = _doe_config_param_impl,
    attrs = {
        "key": attr.string(doc='The substitution key in the config template. If not given, the uppercase target name is used'),
        "values": attr.string_list(mandatory=True, allow_empty=False),
        "naming": attr.string(doc='The contribution of the parameter to the filename. Default is "{key}_{value}".'),
        "always_contribute_to_naming": attr.bool(),
    },
)


def _doe_config_impl(ctx):
    # regroup all parameter naming convention in dictionary
    naming_dict = {p[DoeParamInfo].key: p[DoeParamInfo].naming for p in ctx.attr.params}

    # gather all doe config parameters in a single dictionary
    doe_dict = {p[DoeParamInfo].key: p[DoeParamInfo].values for p in ctx.attr.params}

    # generate doe configuration files
    counter = 0
    cfgs = []
    exps = _doe_list(doe_dict)
    for expe in exps:
        # set filename for the experiment
        if ctx.attr.use_params_to_name_files:
            filename = config_filename(ctx.label.name, expe, naming_dict)+".yaml"
        else:
            filename = ctx.attr.filename_pattern.format(name=ctx.label.name, index=counter)
            counter = counter + 1
        cfg = ctx.actions.declare_file(filename)

        # create config file from template
        ctx.actions.expand_template(
            template = ctx.file.template,
            output = cfg,
            substitutions = dict({"{%s}" % k: v for k,v in expe.items()}, **ctx.attr.substitutions),
        )
        cfgs.append(cfg)

    # Returns the list of generated files + the list of associated expe parameters.
    # Files are not added as runfiles because you have the <config>.files filegroup for that.
    return [
        DefaultInfo(files=depset(cfgs)),
        DoeConfigInfo(files=cfgs, exps=exps, naming=naming_dict, prefix=ctx.label.name),
    ]


_doe_config = rule(
    implementation = _doe_config_impl,
    attrs = {
        "template": attr.label(mandatory=True, allow_single_file=True),
        "params": attr.label_list(mandatory=True, providers=[DoeParamInfo]),
        "substitutions": attr.string_dict(),
        "filename_pattern": attr.string(default="{name}_{index}.yaml"),
        "use_params_to_name_files": attr.bool(default=True),
    },
)


def doe_config(name, visibility=None, **kwargs):
    _doe_config(
        name = "{}".format(name),
        visibility = visibility,
        **kwargs
    )
    native.filegroup(
        name = "{}.files".format(name),
        srcs = [":{}".format(name)],
        visibility = visibility,
    )
    native.genrule(
        name = "_{}_matrix".format(name),
        outs = ["{}.mat".format(name)],
        srcs = [":{}.files".format(name)],
        cmd = "for src in $(SRCS); do echo $${src#$(BINDIR)/}; done >> $@",
        visibility = visibility,
    )
    _doe_config_list(
        name = "{}.list".format(name),
        deps = [":{}".format(name)],
        data = [":{}.files".format(name)],
    )


def config_filename(name, param_dict, naming_dict, sep="_"):
    s = name
    for item in param_dict.items():
        ss = naming_dict.get(item[0]).format(stringify_value(item[1]))
        if len(ss) > 0:
            s = s + sep + ss
    return s


def stringify_value(value):
    """Transform value into a human-friendly string

    Examples:
      [4, 8, 15, 16] -> 4x8x15x16
      ['p','q','r']  -> p,q,r
    """
    value_str = value
    for char in [" ", "[", "]", "_"]:
        value_str = value_str.replace(char, "")
    if value.find("['") >= 0:
        value_str = value_str.replace("'", "")
    else:
        value_str = value_str.replace(",", "x")
    return value_str


def _doe_list(doe_dict):
    doe_list = []
    keys = doe_dict.keys()
    vals = doe_dict.values()
    for idx in _doe_list_idx(doe_dict):
        doe_list.append({keys[i]: vals[i][idx[i]] for i in range(len(idx))})
    return doe_list

def _doe_list_idx(doe_dict):
    "the poor man solution when you can't use while loops or recursivity..."
    v = doe_dict.values()
    count = len(v)
    if count > 5:
        fail('number of parameters > 5 is not supported :(')
    args = [v[i] for i in range(count)]
    return _enum_doe_fns[count](*args)

def _rl(v):
    return range(len(v))

def _doe_list_idx_1(v1):
    return [(i) for i in _rl(v1)]

def _doe_list_idx_2(v1, v2):
    return [(i,j) for i in _rl(v1) for j in _rl(v2)]

def _doe_list_idx_3(v1, v2, v3):
    return [(i,j,k) for i in _rl(v1) for j in _rl(v2) for k in _rl(v3)]

def _doe_list_idx_4(v1, v2, v3, v4):
    return [(i,j,k,l) for i in _rl(v1) for j in _rl(v2) for k in _rl(v3) for l in _rl(v4)]

def _doe_list_idx_5(v1, v2, v3, v4, v5):
    return [(i,j,k,l,m) for i in _rl(v1) for j in _rl(v2) for k in _rl(v3) for l in _rl(v4) for m in _rl(v5)]

_enum_doe_fns = {
    1: _doe_list_idx_1,
    2: _doe_list_idx_2,
    3: _doe_list_idx_3,
    4: _doe_list_idx_4,
    5: _doe_list_idx_5,
}
