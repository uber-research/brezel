# This file is just a template example to demonstrate rule `doe_config`
training:
  model:
    name: {ALGO}
    load:
      value: False
      checkpoint_base_path: %{PATH}
      checkpoint_id: 1
    policy:
      value: mlp
      type:
        value: custom
        layers: {LAYER}

  n_steps: {N_STEPS}
