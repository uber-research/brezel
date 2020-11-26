import logging
import tarfile
import configparser
from pathlib import Path
from google.cloud import storage

config = configparser.ConfigParser()
config.read('./external/brezel_defaults/infra/gcp.ini')
SERVICE_ACCOUNT_FILE = config.get('AUTH', 'SERVICE_ACCOUNT_FILE')

def download_bucket(folder: str, destination: Path, bucket: str = 'atcp-data') -> None:
    """Recursively download folder from GCS

    Args:
        folder: the folder on GCS that should be downloaded
        destination: the directory where the folder should be downloaded
        bucket: the unique bucket name on GCP
    """
    sa = Path(SERVICE_ACCOUNT_FILE)
    client = storage.Client.from_service_account_json(sa) if sa.exists() else storage.Client()

    folder = folder.rstrip('/')

    def _recursive(cur):
        blobs = client.list_blobs(bucket, prefix=folder)
        for blob in blobs:
            cur = blob.name.replace(folder, str(destination))
            if cur.endswith('/'):
                if cur.startswith(str(destination)):
                    continue
                _recursive(cur)
            elif Path(cur).exists():
                continue
            else:
                Path(cur).parent.mkdir(parents=True, exist_ok=True)
                blob.download_to_filename(cur)
                logging.debug(f'Downloaded {cur}')

    _recursive(folder)


def extract_all_tar_gz(folder: Path) -> None:
    """Extract and remove all archives in folder

    Args:
        folder: the directory containing the tar.gz files to extract.
    """
    logging.info(f'Extract all tar.gz in {folder}')

    def extract_tar(path: Path):
        logging.debug(f'Extract {path}')
        with tarfile.open(path, 'r:gz') as tar:
            tar.extractall(path.parent)
            path.unlink()

    [extract_tar(p) for p in folder.glob('*.tar.gz')]
