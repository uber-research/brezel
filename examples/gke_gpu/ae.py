from dataclasses import dataclass

import torch
from torch import nn

@dataclass
class ModelConfig:
    input_shape: 'typing.Any'

class AE(nn.Module):
    """
    Class defining the main architecture of the network
    """
    def __init__(self, model_config: ModelConfig):
        super(AE, self).__init__()

        # Setting sizes
        input_size = model_config.input_shape
        width = 128

        # Setting those as members in __init__ ro register them as parameters
        self.enc_hidden = nn.Linear(input_size, width)
        self.enc_output = nn.Linear(width,      width)
        self.dec_hidden = nn.Linear(width,      width)
        self.dec_output = nn.Linear(width,      input_size)

    def forward(self, x):
        """
        Implementation of forward network architecture
        """
        # First encoder layer
        enc_hidden_a = torch.relu(self.enc_hidden(x))

        # Second encoder layer
        code = torch.relu(self.enc_output(enc_hidden_a))

        # First decoder layer
        dec_hidden_a = torch.relu(self.dec_hidden(code))

        # Second decoder layer (output_size = input_size)
        reconstructed = torch.relu(self.dec_output(dec_hidden_a))

        return reconstructed
