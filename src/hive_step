from mrjob.job import MRJob
from mrjob.step import JarStep


class SetupHiveMetastore(MRJob):

    def configure_args(self):
        super(SetupHiveMetastore, self).configure_args()
        self.add_passthru_arg('--jar-region')

    def steps(self):
        return [
            JarStep(
                jar='s3://{}.elasticmapreduce/libs/script-runner/script-runner.jar'.format(self.options.jar_region),
                args=['s3://tg-cloud-store-dev/admin/postgres-hive-metastore.sh'],
            ),
        ]


if __name__ == '__main__':
    SetupHiveMetastore.run()
