import logging
import os.path
import sys

from mrjob.conf import load_opts_from_mrjob_conf
from mrjob.emr import EMRJobRunner

from region_configs import (
    _add_subnet,
    _add_key_pair,
    _add_tmp_dir,
)


DATE_FMT = '%Y-%m-%d %H:%M:%S'
LOG_FMT = '%(asctime)s|%(levelname)s|%(name)s|%(lineno)d - %(message)s'

logging.basicConfig(
    level=logging.INFO,
    format=LOG_FMT,
    datefmt=DATE_FMT,
    stream=sys.stdout
)


logger = logging.getLogger('launch-cluster')


def conf_path():
    return os.path.abspath(
        os.path.join(
            os.path.expanduser(os.path.dirname(__file__)),
            '..',
            'build',
            'user_config.yml'
        )
    )


def build_config():
    runner_kwargs = dict()
    opts = load_opts_from_mrjob_conf('emr', conf_path=conf_path())
    for _, kwargs in opts:
        runner_kwargs.update(kwargs)
    _add_subnet(runner_kwargs)
    _add_key_pair(runner_kwargs)
    _add_tmp_dir(runner_kwargs)
    logger.info('build_cinfig() -- conf_path: %s', conf_path())
    return runner_kwargs


def main():
    runner_kwargs = build_config()
    logger.info('main() -- runner_kwargs: %s', runner_kwargs)
    emr_client = EMRJobRunner(**runner_kwargs)
    cluster_id = emr_client.make_persistent_cluster()
    logger.info('Cluster-id: %s', cluster_id)

    emr_client = EMRJobRunner(
        mr_job_script='src/hive_step.py',
        cluster_id=cluster_id,
        input_paths=['/dev/null'],
        extra_args=['--jar-region', runner_kwargs['region']],
        **runner_kwargs
    )
    emr_client.run()


if __name__ == '__main__':
    main()
