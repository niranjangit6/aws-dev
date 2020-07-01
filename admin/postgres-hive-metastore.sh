#!/bin/bash

sudo /sbin/stop hive-server2
sudo /sbin/stop hive-hcatalog-server

sudo python /mnt/opt/hive/update-hive-xml.py
sudo /usr/lib/hive/bin/schematool -validate -dbType postgres || /usr/lib/hive/bin/schematool -initSchema -dbType postgresql

sudo /sbin/start hive-hcatalog-server
sudo /sbin/start hive-server2
