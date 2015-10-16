#! /usr/bin/env python

import os
import json
import platform
import click
import jinja2

@click.command()
@click.option('--template-file', help='Template file that has to be specialized')
@click.option('--json-file', help='JSON file from which the template has to be specialized')
@click.option('--output-dir', default="build", help='Folder where the dotfiles will be staged')

def generate(template_file, json_file, output_dir):
    # Read in the JSON DB file
    with open(json_file) as db_file:
        json_data = json.load(db_file)
    # Add some entries into the database
    json_data["HOME_DIR"] = os.environ["HOME"]
    # Handle the __UNAME__ tag
    if '__UNAME__' in json_data:
        uname = platform.uname()[0]
        platform_specifc = json_data["__UNAME__"][uname]
        json_data.update(platform_specifc)
        json_data.pop('__UNAME__', None)

    # Read in the templated file
    template_dir = os.path.dirname(os.path.abspath(template_file))
    env = jinja2.Environment(loader=jinja2.FileSystemLoader(template_dir))
    template = env.get_template(os.path.basename(template_file))

    # Write out to the file
    output_file = output_dir + '/' + os.path.basename(template_file)
    with open(output_file, 'w') as out_file:
      out_file.write(template.render(json_data))

if __name__ == '__main__':
    generate()
