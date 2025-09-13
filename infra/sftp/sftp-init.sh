#!/bin/sh
# /etc/sftp.d/init.sh

# lookup foo’s numeric UID and GID
UID=$(id -u foo)
GID=$(id -g foo)

# chown the entire upload dir
chown -R "${UID}:${GID}" /home/foo/upload
