from dataclasses import dataclass
import os
import typing

import torch
import torch.cuda
import torch.utils.data
from torch import nn, optim
from torchvision import datasets, transforms

from tensorboard import program
from torch.utils.tensorboard import SummaryWriter

from examples.gke_gpu.ae import ModelConfig, AE
from infra import doe

@dataclass
class AEConfig:
    train_ds: 'typing.Any'
    test_ds: 'typing.Any'
    kwargs: 'typing.Any'
    batch_size: int
    input_dir: str
    output_dir: str
    seed: int = 1000

input_dir = '../data'

config = AEConfig(
    train_ds = datasets.MNIST(input_dir, train=True, download=True, transform=transforms.ToTensor()),
    test_ds = datasets.MNIST(input_dir, train=False, download=True, transform=transforms.ToTensor()),
    batch_size = 100,
    input_dir = input_dir,
    output_dir = '/tmp/results',
    kwargs = {}
)

# Data loaders
train_data_loader = torch.utils.data.DataLoader(config.train_ds, config.batch_size, shuffle=True, **config.kwargs)
test_data_loader = torch.utils.data.DataLoader(config.test_ds, config.batch_size, shuffle=True, **config.kwargs)

# Configuring Torch runtime
torch.manual_seed(config.seed)
print("CUDA available? {}".format(torch.cuda.is_available()))
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Tensorboard
tb = program.TensorBoard()
tb.configure(argv=[None, '--logdir', config.output_dir, '--host', '0.0.0.0'])
url = tb.launch()
print(url)

# Torch writing for Tensorboard
writer = SummaryWriter(config.output_dir, flush_secs=1)

# Creating AE model
model_config = ModelConfig(input_shape = 784)
model = AE(model_config).to(device)
# Creating a loss
loss_fn = nn.MSELoss()

# Create an optimizer
lr = 1e-3
optimizer = optim.Adam(list(model.parameters()), lr)

# Training
n_epochs = 10
for epoch in range(0,n_epochs):
    loss = 0
    for batch_features, _ in train_data_loader:
        batch_features = batch_features.view(-1, 784).to(device)

        optimizer.zero_grad()

        outputs = model(batch_features)
        train_loss = loss_fn(outputs, batch_features)

        train_loss.backward()

        optimizer.step()

        loss += train_loss.item()

    loss = loss / len(train_data_loader)
    writer.add_scalar('Loss/train', loss, epoch)

    print("epoch : {}/{}, loss = {:.6f}".format(epoch + 1, n_epochs, loss))

# Closing Tensorboard writer
writer.close()

# Saving Pytorch model
torch.save(model.state_dict(), os.path.join(config.output_dir, "model.pt"))

# Writing sentinel file to trigger K8S job completion
doe.IO.done(config.output_dir)
