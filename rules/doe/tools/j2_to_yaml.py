#!/usr/bin/env python
from jinja2 import Template
import sys
import argparse

"""Declare script arguments"""
parser = argparse.ArgumentParser()
parser.add_argument("template")
parser.add_argument("parameters")
parser.add_argument("output")
args = parser.parse_args()

"""Read parameters input file"""
with open(args.parameters, 'r') as p:
    params = [line.rstrip('\n') for line in p]

"""Render input template with parameters"""
with open(args.template, 'r') as tpl:
    rendered = Template(tpl.read()).render(params=params)

"""Write rendered template in output file"""
with open(args.output, 'w') as out:
    out.write(rendered+'\n')
