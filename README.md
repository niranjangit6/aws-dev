## Setup
1. Run `setup.sh`. This will create a `conf` directory.
2. Copy your AWS key and secret key into `conf/access_keys.yml`.
3. Enter the number of cores nodes you want into `conf/machines.yml`.
4. On the AWS S3 page, go to `s3://tg-cloud-store-dev/<username>` where `<username>` should be the username on instance. Create a `notebooks` subfolder. Full path should look like `s3://tg-cloud-store-dev/<username>/notebooks`. Copy any notebooks there that you want.

## Launch
Set the region and zone in `conf/config.yml`.

Run `launch_cluster.sh`. Wait until the program finally completes (i.e. returns to the command line). You'll see some logging indicating success (or failure).

An additional `build` directory will be created. You can ignore this.

## Use
A notebook server with all your notebooks should appear on AWS! To see them, go to the url on port `5555`.

Notebooks on your cluster are saved _locally_. They need to be synced with S3. It is recommended to add a cell to the top of all your aws notebooks with:

`!aws s3 sync . s3://tg-cloud-store-dev/<username>/notebooks/`

To only include python notebooks, you should set the line to

`!aws s3 sync . s3://tg-cloud-store-dev/<username>/notebooks --exclude "*" --include "*.ipynb"`

## What's in this repository?

- `admin`: A few files needed to properly setup of the cluster. They are already stored in `s3://tg-cloud-store-dev/admin` and do not have to be uploaded again. They are here for reference.
- `src`: Main python code for launching the cluster and add the step to setup Hive.
- `templates`: These are the template files for all the configuration parameters. They get copied to `conf` where you can edit them.
