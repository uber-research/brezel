import sys
import click
from notebook import notebookapp

@click.command()
@click.option('--notebook-dir',
              help='The directory with the notebooks',
              default=".")
@click.option('--port',
              help='Port used by the webapp',
              default="8888")
def run_notebook_webapp(notebook_dir, port):
    """
    Programmatic way of starting a Jupyter Notebook webapp
    """
    NotebookApp = notebookapp.NotebookApp
    nbapp = NotebookApp()

    # Args passed to the Jupyter notebook app as if you were running
    # The CLI jupyter notebook
    args = [
        "--notebook-dir", notebook_dir,
        "--no-browser",
        "--ip", "0.0.0.0",
        "--port", port,
        "--allow-root"
    ]
    return nbapp.launch_instance(args)

if __name__ == '__main__':
    sys.exit(run_notebook_webapp())
