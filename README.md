# Kubernetes Multi-Arch with Go and Nodejs

Proxy Users here is use extra part to start with:

0. [Proxy PSA for Proxy Users](docs/0-ProxyPSA.md)

For everyone else this guide has 5 main parts:
1. [Official Docker Repos and Multi-Arch Primer](docs/1-Official-Multiarch.md)
2. [Build best practice nodejs docker images](docs/2-Best-Practice-Nodejs.md)
3. [Build best practice go docker images](docs/3-Best-Practice-go.md)
4. [Build multi-arch docker images](docs/4-Build-MultiArch.md)
5. [Deploy these images to your kubernetes cluster](docs/5-Deploy-to-Kubernetes.md)

## Prerequisites
* Have an up and running Kubernetes cluster
* Setup access to that cluster using kubectl
* Download docker on your workstation

This Tutorial will start by looking at what Official Repositories are and how to build from them. Then, it will shine light on how to tell if an app will run on your platform (architecture). Next, we will look at how best to build images for go and nodejs in docker with examples and then actually build these images with Multi-Architecture manifests. Finally, we will use these images or my pre-build images to deploy to a kubernetes cluster.

## Get the Code
The code for this tutorial is on this github. If you have git installed it can be brought onto your computer with `git clone https://github.com/siler23/MultiArchDockerICP.git`. If you don't have git or don't want to clone the repo, you can use the download link in the top right corner of this page. ![Download Image](images/DownloadRepo.png)
## Let's Begin
**Non-Proxy Users** (Regular Users) Start Here:</br> [Official Docker Repos and Multi-Arch Primer](docs/1-Official-Multiarch.md)

**Proxy Users** Start Here:<br/> [Proxy PSA for Proxy Users](docs/0-ProxyPSA.md)
## Additional Topics
Additional topics to look at after finishing everything here are:
1. [Building a Helm Chart from kubernetes yaml files](https://www.ibm.com/blogs/bluemix/2017/10/quick-example-helm-chart-for-kubernetes/)
2. [Cross-building images to build x86 and z images on your local x86 workstation](https://stefanscherer.github.io/cross-build-nodejs-with-docker/) Note: Alpine has been made multi-arch after the posting of the linked article and the base image now runs on s390x/z.

### IBM Guidance on Containers and ICP Multi-Arch Process
- [IBM Guidance on running docker containers on IBM Z PDF](http://public.dhe.ibm.com/software/dw/linux390/docu/l177vd00.pdf)</br>

- [IBM Cloud Private Enablement Guide for ISV](https://developer.ibm.com/linuxonpower/ibm-cloud-private-on-power/isv-guide/)
