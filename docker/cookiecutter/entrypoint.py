#!/usr/bin/env python
import json
import click
import pathlib
from cookiecutter.main import cookiecutter


@click.command()
@click.argument('template', type=click.Path(exists=True, file_okay=False))
@click.option('--prompt', '-p', multiple=True)
@click.option('--value', '-v', multiple=True, type=str, nargs=2)
def main(template, prompt, value):
    print("Running cookiecutter")

    # Load config from cookiecutter.json
    config_file = pathlib.Path(template) / "cookiecutter.json"
    with config_file.open() as f:
        cfg = json.load(f)

    # Prompt user for extra context
    context = {}
    for p in prompt:
        if p not in cfg.keys():
            raise RuntimeError(f'{p} is not declared in cookiecutter.json')
        context[p] = click.prompt(p, default=cfg[p])

    # Overwrite some default
    for k, v in value:
        if k not in cfg.keys():
            raise RuntimeError(f'{p} is not declared in cookiecutter.json')
        context[k] = v

    # Run cookiecutter
    cookiecutter(
        template,
        no_input=True,
        extra_context=context
    )


if __name__ == "__main__":
    main()
