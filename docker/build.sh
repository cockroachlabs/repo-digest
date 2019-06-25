#!/bin/bash

set -exo pipefail

mv docker/entrypoint.sh /
mv templates/cockroachdb /cockroachdb.template

# Build the binary and move it into $PATH
go build -v .
mv repo-digest /usr/local/bin

# Install a simple MTA.
apt-get update -y
apt-get install ssmtp -y

# Link config file into place.
ln -sf /secrets/ssmtp.conf /etc/ssmtp/

# Delete unneeded files.
rm -rf /var/lib/apt/lists/* /go $WORKDIR
