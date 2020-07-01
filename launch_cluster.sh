#!/bin/bash

if [[ $# -gt 1 ]]; then
    echo "Expecting zero or one arguments to be passed."
    return 1
fi

if [[ $# -eq 1 ]]; then
    case "$1" in
        --research | -r)
            echo "Starting a research cluster"
            AWS_ENV=$USER
            ;;
        --production | -p)
            echo "Starting a production cluster"
            AWS_ENV="production"
            ;;
        *)
            echo "Illegal option $1."
            return 1
            ;;
    esac
fi

if [[ $# -eq 0 ]]; then
    echo "No arguments passed. Starting a research cluster, by default."
    AWS_ENV=$USER
fi

echo "AWS_ENV is"
echo $AWS_ENV

mkdir -p build
sed "s/<user>/$AWS_ENV/" aws_bootstrap.sh > build/user_aws_bootstrap.sh
sed "s/<user>/$AWS_ENV/" conf/config.yml > build/user_config.yml

CLOUD_STORE=s3://tg-cloud-store-dev

aws s3 cp build/user_aws_bootstrap.sh $CLOUD_STORE/$AWS_ENV/aws_bootstrap.sh

aws s3 cp --recursive conf/user_home_files $CLOUD_STORE/$USER/user_home_files

echo " Going to call python src/main.py /dev/null"
python src/main.py /dev/null
