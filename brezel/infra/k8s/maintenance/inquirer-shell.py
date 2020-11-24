from PyInquirer import prompt
from jinja2 import Template
import getpass
import tempfile
import os

# NODEPOOLS and TAINTS are exported by 'py_vars'
from brezel.infra.k8s.maintenance.vars import NODEPOOLS, TAINTS

# Internal variables made available via the 'data' attribute (BUILD)
_TEMPLATE = "brezel/infra/k8s/maintenance/pod.yaml.j2"
_SCRIPT = "brezel/infra/k8s/maintenance/simple-shell.sh"

# The list of the available images
IMAGES = [
    "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
]

def get_parameters_from_cli():
    widget = [
        {
            'type': 'list',
            'name': 'nodepool',
            'message': 'Nodepool:',
            'choices': NODEPOOLS
        },
        {
            'type': 'list',
            'name': 'image',
            'message': 'Image:',
            'choices': IMAGES
        }
    ]
    result = prompt(widget)
    nodepool = result['nodepool']
    image = result['image']
    return (nodepool, image)

def render_pod_yaml(podname, nodepool, image):
    with open(_TEMPLATE, 'r') as tpl:
        taints = [taint.split(':') for taint in TAINTS[nodepool]] if nodepool in TAINTS else []
        taint_keys = [t[0] for t in taints]
        taint_values = [t[1] for t in taints]
        j2tpl = Template(tpl.read())
        rendered = j2tpl.render(
            podname=podname,
            image=image,
            nodepool=nodepool,
            toleration_keys=taint_keys,
            toleration_values=taint_values
        )
        return rendered

if __name__ == "__main__":
    name = f'{getpass.getuser()}-maintenance-shell'
    pool, img = get_parameters_from_cli()
    yaml = render_pod_yaml(name, pool, img)
    with tempfile.NamedTemporaryFile(suffix='.yaml') as fp:
        fp.write(yaml.encode('utf-8'))
        fp.flush()
        os.system(f'{_SCRIPT} {fp.name}')
