import importlib

doe_impl = None

# Check which DOE implementation is available and load it
try:
    doe_impl = importlib.import_module(".local.doe", package="infra.doe")
except:
    try:
        doe_impl = importlib.import_module(".remote.doe", package="infra.doe")
    except:
        print("Neither local nor remote doe library was found")

def load_all_public(module):
    """ Mimicing from doe_impl import * """
    module_dict = module.__dict__

    # Getting list of public attributes and importing them
    try:
        to_import = module.__all__
    except AttributeError:
        to_import = [name for name in module_dict if not name.startswith('_')]

    globals().update({name: module_dict[name] for name in to_import})

if doe_impl is not None:
    load_all_public(doe_impl)

