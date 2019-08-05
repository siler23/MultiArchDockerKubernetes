# From Docker to Kubernetes - Multi-Arch with Go and Nodejs

Proxy Users here is your extra part to start with:

[Hello Proxy Users](0-ProxyPSA.md)

For everyone else this guide has 5 main parts:

1. [Getting Official with Multi-arch Images](1-Official-Multiarch.md)
2. [Building Best-practice Node.js Docker Images](2-Best-Practice-Nodejs.md)
3. [Building Best-practice Go Docker Images](3-Best-Practice-go.md)
4. [Building Multi-arch Docker Images](4-Build-MultiArch.md)
5. [Kubernetes Time](5-Deploy-to-Kubernetes.md)

## Prerequisites
* Have an up and running Kubernetes cluster
* Setup access to that cluster using kubectl
* Download docker on your workstation

This guide will start by looking at what Official Repositories are and how to build from them. Then, it will shine light on how to tell if an app will run on your platform (architecture). Next, we will look at how best to build images for go and nodejs in docker with examples and then actually build these images with Multi-Architecture manifests. Finally, we will use these images or my pre-built images to deploy to a Kubernetes cluster.

## Get the Code
The code for this guide is on the accompanying github at `https://github.com/siler23/MultiArchDockerICP`. You can also access this page by clicking on the github icon on the top right of every page.

![Github link](images/Go_To_Repo.png)

If you have git installed, it can be brought onto your computer with:

```
git clone https://github.com/siler23/MultiArchDockerICP.git
```

If you don't have git or don't want to clone this repo, you can use the download link in the top right corner of the github page. 

![Download Image](images/DownloadRepo.png)

## Search to your Heart's Content
Search the docs for the content you want by using the search bar at the top of each page like so for hello world.

![Search my pages](images/search_multiarch.png)

## Let's Begin
**Non-Proxy Users** (Regular Users) Start Here:</br> [Official Docker Repos and Multi-Arch Primer](1-Official-Multiarch.md)

**Proxy Users** Start Here:<br/> [Proxy PSA for Proxy Users](0-ProxyPSA.md)
## Possible Next Step
[Building a Helm Chart from Kubernetes yaml files](https://www.ibm.com/blogs/bluemix/2017/10/quick-example-helm-chart-for-kubernetes/)

### IBM Guidance on Containers and ICP Multi-Arch Process
- [IBM Guidance on running docker containers on IBM Z PDF](http://public.dhe.ibm.com/software/dw/linux390/docu/l177vd00.pdf)</br>

- [IBM Cloud Private Enablement Guide for ISV](https://developer.ibm.com/linuxonpower/ibm-cloud-private-on-power/isv-guide/)

### Shoutout to Mkdocs
I made this site with [mkdocs](https://www.mkdocs.org) using the [material](https://squidfunk.github.io/mkdocs-material/) theme.
