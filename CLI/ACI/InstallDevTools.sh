#!/usr/bin/env bash

#############################################################################################################
#                                                                                                           #
# This script does the following things:                                                                    #
#   1. Installs the Azure CLI and its dependencies.                                                         #
#   2. Installs Docker CE and all its dependencies.                                                         #
#   3. Installs the .NET SDK and the Azure Functions Core Tools.                                            #
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
echo "...Azure CLI:"
echo ""

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo ""
echo "...Docker:"
echo ""

# https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt-get update
sudo apt-get install --assume-yes apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install --assume-yes docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

echo ""
echo "...DotNet SDK:"
echo ""

# https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#linux

# https://dotnet.microsoft.com/download/linux-package-manager/ubuntu18-10/sdk-current
wget -q https://packages.microsoft.com/config/ubuntu/18.10/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install --assume-yes dotnet-sdk-2.2

echo ""
echo "...Azure Functions Core Tools:"
echo ""

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update

sudo apt-get install --assume-yes azure-functions-core-tools

echo ""
echo "DEV TOOLS: Installied."
echo ""

