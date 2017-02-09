from __future__ import print_function

from bioblend.galaxy import GalaxyInstance
from bioblend.galaxy.users import UserClient
from bioblend.galaxy.workflows import WorkflowClient

from os import environ
from os import listdir
from os.path import isfile, join
import argparse


def __main__():
    parser = argparse.ArgumentParser(description = 'Import workflows from a local directory')
    parser.add_argument('-p', '--port', help = 'port number from your docker container that you map to your host machine. The default is 80', default = '80')
    parser.add_argument('-k', '--key', help = 'user API key')
    args = parser.parse_args()
    
    # port and api key
    port = args.port
    api_key = args.key
    
    # galaxy client instance
    galaxy_home = environ['GALAXY_HOME']
    galaxy_client = GalaxyInstance(url = "http://127.0.0.1:" + port, key = api_key)
    
    if galaxy_client:
        # workflow client instance
        workflow_client = WorkflowClient(galaxy_client)
        
        my_workflows_dir = environ['GALAXY_HOME'] + '/my_workflows'
        workflow_files = []
        for f in listdir(my_workflows_dir):
            if isfile(join(my_workflows_dir, f)):
                f_path = join(my_workflows_dir, f)
                workflow_client.import_workflow_from_local_path(f_path)
                print('Imported workflow: ' + f)

if __name__ == '__main__': __main__()
