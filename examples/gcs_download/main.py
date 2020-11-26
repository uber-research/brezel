import sys
from pathlib import Path
from brezel.infra.gcp.gcs import download_bucket

if __name__ == "__main__":
    folder = 'demo/'
    outdir = Path('out/')
    print(f'Download {folder} in {outdir}')
    download_bucket(folder, destination=outdir)
    data_file = outdir / 'data.txt'
    with data_file.open() as f:
        print(f.read())
