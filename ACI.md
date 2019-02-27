# Deploying The Streaming App Into Azure

Return to [Overview](ReadMe.md).

---
In this step, we will deploy the streamer app into Azure to run in Container Instances. In order to do so, we will need to make sure we have a an active Git client and Docker installation that we can use. The instructions below assume that you don't have either installed; if you already have these tools installed and prefer to use the local versions, feel free to do so.

1. Create a Virtual Machine via the Azure Portal using the CentOS Linux image. Be sure to enable inbound SSH as part of the creation process.
1. Once deployment has completed successfully, remote login to your new VM using a variant of the following command:
  ```sh
  ssh $user@$hostip # example mannie@123.45.67.89
  ```
1. Once we've logged in, the following commands to install Brew:
  ```sh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  echo "export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH" >> .bash_profile
  source .bash_profile
  ```
1. Install Git.
  ```sh
  brew install git
  ```
1. Install Docker and its dependencies, as per the [Docker documentation](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/centos/#install-using-the-repository)).
  ```sh
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce
  ```
1. Start the Docker engine.
  ```sh
  sudo systemctl start docker
  ```
1. Verify that Docker installed correctly by running the `hello-world` image.
  ```sh
  sudo docker run hello-world
  ```
1. Clone the [Event Streamer](https://github.com/mannie/EventStreamer) app and navigate into the project's root directory.
  ```sh
  git clone https://github.com/mannie/EventStreamer.git
  cd EventStreamer
  ```
1. Build the app and run it locally.
  ```sh
  sudo docker build --tag streamer .
  sudo docker run --interactive --tty --rm streamer
  ```
1. Create a Container Registry via the Azure Portal.
1. Deploy the container image into Azure.
  ```sh
  registry=address.to.registry # example manniesregistry.azurecr.io

  sudo docker login $registry
  sudo docker tag streamer $registry/streamer
  sudo docker push $registry/streamer
  ```


---
Move on to [Ingesting events into Event Hubs](EventHubs.md).
