#!/bin/bash

mkdir -p conf

mkdir -p conf/user_home_files

if [ ! -e access_key.yml ];
then
	echo "Creating access_key.yml"
	cp templates/access_keys.yml.template conf/access_keys.yml
fi


if [ ! -e applications.yml ];
then
	echo "Creating applications.yml"
	cp templates/applications.yml.template conf/applications.yml
fi


if [ ! -e config.yml ];
then
	echo "Creating config.yml"
	cp templates/config.yml.template conf/config.yml
fi


if [ ! -e machines.yml ];
then
	echo "Creating machines.yml"
	cp templates/machines.yml.template conf/machines.yml
fi
