#!/usr/bin/env python
import sys
import tarfile
import tempfile
import tensorboard
import time


def wait_for_quitting():
    print('Press ctrl-c to quit')
    try:
        while True:
            time.sleep(5)
    except KeyboardInterrupt:
        exit(0)


if __name__ == "__main__":
    log_tar = tarfile.open(sys.argv[1])
    with tempfile.TemporaryDirectory() as tdir:
        log_tar.extractall(path=tdir)
        tb = tensorboard.program.TensorBoard()
        tb.configure(argv=[None, '--logdir', tdir, '--host', '0.0.0.0'])
        url = tb.launch()
        print(f'\nTensorboard is available from {url}')
        wait_for_quitting()
