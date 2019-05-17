#!/usr/bin/env bash

#############################################################################################################
#                                                                                                           #
# This script does the following things:                                                                    #
#   1. Installs Docker CE and all its dependencies.                                                         #
#   2. Installs Git.                                                                                        #
#                                                                                                           #
# Given the nature of this script, it must be executed with elevated privileges, i.e. with `sudo`.          #
#                                                                                                           #
# Remember:                                                                                                 #
#     Do NOT be in the habit of executing scripts from the internet with root-level access to your machine. #
#     Only trust well-known publishers.                                                                     #
#                                                                                                           #
#############################################################################################################

echo ""
echo "DEV TOOLS: Installing..."

echo ""
echo "...Docker:"
echo ""

# https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/centos/#install-using-the-repository
sudo yum install --assume-yes yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install --assume-yes docker-ce

sudo systemctl start docker

sudo docker run hello-world

echo ""
echo "...Git:"
echo ""

sudo yum install --assume-yes git

echo ""
echo "DEV TOOLS: Installed."
echo ""
