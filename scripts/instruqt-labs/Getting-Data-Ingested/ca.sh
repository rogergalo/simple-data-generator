#!/bin/bash

# Variables
SRC_CERT="/etc/ssl/certs/nginx-selfsined.crt"
DEST_CERT="/usr/local/share/ca-certificates/ca.crt"
DEST_HOST1="docker"
DEST_HOST2="syslog-shipper"
DEST_HOST3="syslog-aggregator"

# HOST 1

echo "Copying $SRC_CERT to $DEST_HOST1:$DEST_CERT ..."
scp "$SRC_CERT" "$DEST_HOST1:/tmp/ca.crt"
if [ $? -ne 0 ]; then
    echo "SCP failed! Exiting."
    exit 1
fi

echo "Moving cert to $DEST_CERT and updating CA store on $DEST_HOST ..."
ssh "$DEST_HOST1" "sudo mv /tmp/ca.crt $DEST_CERT && sudo update-ca-certificates"

if [ $? -eq 0 ]; then
    echo "Certificate installed and CA store updated on $DEST_HOST1."
else
    echo "Failed to update CA store on $DEST_HOST1."
    exit 2
fi

# HOST2

echo "Copying $SRC_CERT to $DEST_HOST2:$DEST_CERT ..."
scp "$SRC_CERT" "$DEST_HOST2:/tmp/ca.crt"
if [ $? -ne 0 ]; then
    echo "SCP failed! Exiting."
    exit 1
fi

echo "Moving cert to $DEST_CERT and updating CA store on $DEST_HOST2 ..."
ssh "$DEST_HOST2" "sudo mv /tmp/ca.crt $DEST_CERT && sudo update-ca-certificates"

if [ $? -eq 0 ]; then
    echo "Certificate installed and CA store updated on $DEST_HOST2."
else
    echo "Failed to update CA store on $DEST_HOST2."
    exit 2
fi

# HOST 3

echo "Copying $SRC_CERT to $DEST_HOST3:$DEST_CERT ..."
scp "$SRC_CERT" "$DEST_HOST3:/tmp/ca.crt"
if [ $? -ne 0 ]; then
    echo "SCP failed! Exiting."
    exit 1
fi

echo "Moving cert to $DEST_CERT and updating CA store on $DEST_HOST3 ..."
ssh "$DEST_HOST3" "sudo mv /tmp/ca.crt $DEST_CERT && sudo update-ca-certificates"

if [ $? -eq 0 ]; then
    echo "Certificate installed and CA store updated on $DEST_HOST3."
else
    echo "Failed to update CA store on $DEST_HOST3."
    exit 2
fi
