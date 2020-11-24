import os
import time
import sys
from pathlib import Path

def _wait_for_data(data_dir, timeout):
    p = Path(f'{data_dir}/READY')
    counter = 0
    while not p.exists():
        time.sleep(1)
        counter += 1
        print(f'waiting for {p}...')
        if counter > timeout:
            sys.exit('Downloading timed out.')

class IO:
    @staticmethod
    def ready(input_dir, timeout=300):
        """
        Waiting until we see a READY file in the input directory 
        """
        _wait_for_data(input_dir, timeout)
        print("Remote input data ready")

    @staticmethod
    def done(output_dir):
        """
        Writing a DONE file in the output directory
        """
        with open(os.path.join(output_dir,'DONE'), 'w') as f:
            print("Output data stored remotely")
