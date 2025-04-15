#!/bin/bash

# Install git and pull down necessary files
git clone https://github.com/iamhowardtheduck/ingestworkshop.git
xz -d /root/ingestworkshop/auth.log.elastic.txt.xz
mv /root/ingestworkshop/auth.log.elastic.txt /root/ingestworkshop/auth.log.elastic
cp /root/ingestworkshop/auth.log.elastic /var/log
chmod 777 /var/log/auth.log.elastic
