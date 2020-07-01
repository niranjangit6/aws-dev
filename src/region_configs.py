import logging
import os

logger = logging.getLogger(__name__)


SUBNETS = {
    'us-east-1e': 'subnet-052fc9404e4ae71d5',
    'us-east-1a': 'subnet-a654aa8d',
    'us-east-1b': 'subnet-8a7cc1fd',
    'us-east-1c': 'subnet-e69649bf',
    'us-east-1d': 'subnet-39cc565c',
    'us-east-1f': 'subnet-5f3bbc53',
    'us-west-2a': 'subnet-004fd4fea936d33fd',
    'us-west-2b': 'subnet-01760d117bf7f8efc',
    'us-west-2c': 'subnet-07c0f24a8a4d83100',
}


KEYS = {
    'us-east-1': 'EMR_OnSpot',
    'us-west-2': 'EC2_Amazon',
}


TMP_DIRS = {
    'us-east-1': 's3://mapredlogs-east-dev/',
    'us-west-2': 's3://mapredlogs/',
}


def _add_subnet(runner_kwargs):
    zone = runner_kwargs.pop('zone', None)
    if zone:
        subnet = SUBNETS.get(zone)
    else:
        logger.exception('Zone not found!')
    if subnet is None:
        logger.exception('Subnet not found for zone "%s"', zone)
    runner_kwargs['subnet'] = subnet


def _add_key_pair(runner_kwargs):
    region = runner_kwargs.get('region')
    if region is None:
        logger.exception('Region not provided!')
    path = os.path.abspath(os.path.expanduser('~'))
    key_pair = KEYS.get(region)
    if key_pair is None:
        logger.exception('Key pair not found for region "%s"!', region)
    runner_kwargs['ec2_key_pair'] = key_pair
    key_file = '{}.pem'.format(key_pair)
    key_path = None
    search_path = [None, '.aws']
    for search in search_path:
        if search:
            key_path = os.path.join(path, search, key_file)
        else:
            key_path = os.path.join(path, key_file)
        if os.path.exists(key_path):
            break
    if key_path is None:
        logger.exception('Key file "%s" not found!', key_file)
    runner_kwargs['ec2_key_pair_file'] = key_path


def _add_tmp_dir(runner_kwargs):
    region = runner_kwargs.get('region')
    if region is None:
        logger.exception('Region not provided!')
    if region not in TMP_DIRS:
        logger.exception('Temp dir not found for region "%s"!', region)
    runner_kwargs['cloud_tmp_dir'] = TMP_DIRS[region]
