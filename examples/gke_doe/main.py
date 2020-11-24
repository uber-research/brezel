import click
from infra import doe

@click.command()
@click.option('--exp-id', help='ID of experiment being run')
@click.option('--output-dir', default='/tmp', help='Directory with result files')
@click.option('--input-dir', default='/data', help='Directory with input files')
def run(exp_id, output_dir, input_dir):
    """
    Test python program that saves a result file
    """
    print(f'Experimental ID: {exp_id}')

    # Download file
    doe.IO.ready(input_dir)
    with open(f'{input_dir}/data.txt') as f:
        print(f'Downloaded file content:\n{f.read()}')

    # Creating empty file
    doe.IO.done(output_dir)

if __name__ == '__main__':
    run()
