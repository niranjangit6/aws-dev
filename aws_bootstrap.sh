#!/usr/bin/env bash
set -ex

export PATH=/usr/local/bin:$PATH

# Postgres support.
sudo yum -y install postgresql95.x86_64
sudo yum -y install postgresql-jdbc
sudo chmod 644 /usr/share/java/postgresql-jdbc.jar

# Environment setup.
aws s3 cp s3://tg-cloud-store-dev/admin/aws_env.sh .
sudo mv aws_env.sh /etc/profile.d
sudo chmod 755 /etc/profile.d/aws_env.sh
source /etc/profile.d/aws_env.sh

# Install packages that can be installed through yum.
sudo yum -y install htop
sudo yum -y install tmux

# Install python packages.
sudo pip install numpy==1.14.5
sudo pip install pandas==0.23.4
sudo pip install matplotlib==2.2.2
sudo pip install pyarrow==0.10.0
sudo pip install llvmlite==0.31.0
sudo pip install fastparquet==0.1.5
sudo pip install wheel==0.34.1
sudo pip install pyspark==2.3.0
sudo pip install six==1.11.0
sudo pip install boto3==1.8.7
sudo pip install shapely==1.6.4.post1
sudo pip install python-geohash==0.8.5
sudo pip install yarn-api-client==0.3.1
sudo pip install psycopg2==2.7.6
sudo pip install s3fs==0.1.6
sudo pip install geopandas==0.4.0
sudo pip install scikit-learn==0.20.3
sudo pip install snowflake-connector-python
sudo pip install jupyter
sudo pip install geopy
sudo pip install seaborn
sudo pip install descartes

# Script for installing Basemap.
aws s3 cp s3://tg-cloud-store-dev/admin/install_basemap.sh /mnt/opt/install_basemap.sh

# Install scala.
cd /mnt
wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm
sudo yum -y install scala-2.11.8.rpm

# Unpack thasos2 and thasosp.
sudo mkdir -p /mnt/opt/packages
sudo chmod 777 /mnt/opt/packages
aws s3 cp s3://tg-cloud-store-dev/admin/thasos2.tar.gz thasos2.tar.gz
tar -xvzf thasos2.tar.gz
mv thasos2 /mnt/opt/packages
aws s3 cp s3://tg-cloud-store-dev/admin/qstreams.tar.gz .
tar -xvzf qstreams.tar.gz
mv qstreams /mnt/opt/packages
aws s3 cp s3://tg-cloud-store-dev/admin/thasosp.tar.gz .
tar -xvzf thasosp.tar.gz
mv thasosp /mnt/opt/packages

# copy user home files
# (if there is a custom .bashrc then it should be appended to the EMR .bashrc
# so that the AWS CLI region is set correctly)
mv ~/.bashrc ~/.bashrc_orig 2> /dev/null

aws s3 sync s3://tg-cloud-store-dev/<user>/user_home_files/ ~/

touch ~/.bashrc
mv ~/.bashrc ~/.bashrc_new
cat ~/.bashrc_orig ~/.bashrc_new > ~/.bashrc
rm ~/.bashrc_orig
rm ~/.bashrc_new

# Setup local jars.
sudo mkdir -p /mnt/opt/jars
sudo chmod 777 /mnt/opt/jars

# S3 output committer.
aws s3 cp s3://tg-cloud-store-dev/admin/s3committer-0.5.5.jar /mnt/opt/jars/s3committer-0.5.5.jar
aws s3 cp s3://tg-cloud-store-dev/admin/s3committer-0.5.5-dev.jar /mnt/opt/jars/s3committer-0.5.5-dev.jar

# Install snowflake connectors.
aws s3 cp s3://tg-cloud-store-dev/admin/spark-snowflake_2.11-2.5.1-spark_2.3.jar /mnt/opt/jars/spark-snowflake_2.11-2.5.1-spark_2.3.jar
aws s3 cp s3://tg-cloud-store-dev/admin/snowflake-jdbc-3.8.7.jar /mnt/opt/jars/snowflake-jdbc-3.8.7.jar

# Launch jupyter notebook on master.
if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
	sudo sysctl net.core.somaxconn=16384
	sudo sysctl net.core.netdev_max_backlog=16000
	sudo sysctl net.ipv4.tcp_max_syn_backlog=16384

	sudo mkdir -p /mnt/etc/hadoop/conf
	sudo chmod 777 /mnt/etc/hadoop/conf
	aws s3 cp s3://tg-cloud-store-dev/admin/yarn-fair-scheduler.xml /mnt/etc/hadoop/conf/yarn-fair-scheduler.xml

	sudo mkdir -p /mnt/opt/hive
	sudo chmod 777 /mnt/opt/hive
	aws s3 cp s3://tg-cloud-store-dev/admin/update-hive-xml.py /mnt/opt/hive/update-hive-xml.py

	echo "Launching jupyter..."

	mkdir -p ~/notebooks
	aws s3 ls s3://tg-cloud-store-dev/<user>/notebooks
	if [[ $? -eq 0 ]];
	then
		aws s3 sync s3://tg-cloud-store-dev/<user>/notebooks/ ~/notebooks/
	fi

	/usr/local/bin/jupyter notebook \
	    --port=5555 \
		--ip=`hostname` \
		--no-browser \
		--notebook-dir=~/notebooks \
		--NotebookApp.token="" > ~/nbserver.log 2>&1 &

	echo "Done."
else
	sudo sysctl net.ipv4.ip_local_port_range="15000 61000"
	sudo sysctl net.ipv4.tcp_fin_timeout=30
fi
