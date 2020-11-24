class IO:
    """
    Load implementation of the DOE Python client library
    """
    @staticmethod
    def ready(input_dir, timeout=None):
        """
        Locally, ready doesn't do anything as the input is supposed to be readily available
        """
        print("Local input data ready")

    @staticmethod
    def done(output_dir):
        """
        Locally, done doesn't do anything as there is no need to upload the output on a remote server
        """
        print("Output data stored locally")
