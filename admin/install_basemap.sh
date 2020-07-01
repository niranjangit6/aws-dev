# Install Basemap.
sudo pip install pyproj==1.9.6

sudo mkdir -p /mnt/basemap_install_staging
cd /mnt/basemap_install_staging

aws s3 cp s3://tg-cloud-store-dev/samuelluo/tar/basemap-1.1.0.tar.gz .
tar -zxvf basemap-1.1.0.tar.gz
cd basemap-1.1.0
cd geos-3.3.3
export GEOS_DIR=/usr/local
./configure --prefix=$GEOS_DIR
sudo make
sudo make install
cd ..
sudo python setup.py install

sudo rm -rf /mnt/basemap_install_staging
