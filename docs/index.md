# From Docker to Kubernetes - Multi-Arch with Go and Nodejs

Proxy Users here is your extra part to start with:

[Hello Proxy Users](0-ProxyPSA.md)

For everyone else this guide has 5 main parts:

1. [Getting Official with Multi-arch Images](1-Official-Multiarch.md)
2. [Learning How to Build Best-practice Node.js Docker Images](2-Best-Practice-Nodejs.md)
3. [Guide to Building Best-practice Go Docker Images](3-Best-Practice-go.md)
4. [Building Multi-arch Docker Images](4-Build-MultiArch.md)
5. [Kubernetes Time](5-Deploy-to-Kubernetes.md)

## Prerequisites

* Have an up and running Kubernetes cluster

* Setup access to that cluster using kubectl

* Register for a DockerHub account following the process outlined on DockerHub <a href="https://success.docker.com/article/how-do-you-register-for-a-docker-id" target="_blank">here</a> 

* Download Docker on your workstation from DockerHub using your newly created free account <a href="https://hub.docker.com/?overlay=onboarding" target="_blank">here</a> 

## What will this Guide do for you?

This guide will start by looking at what Official Repositories are and how to build from them. Then, it will shine light on how to tell if an app will run on your platform (architecture). Next, we will look at how best to build images for go and nodejs in docker with examples and then actually build these images with Multi-Architecture manifests. Finally, we will use these images or my pre-built images to deploy to a Kubernetes cluster.


## What in the Tarnation is a Container?

Application containers make use of linux kernel features to provide lightweight isolation by limiting what a process (running program) can see ([namespaces](http://man7.org/linux/man-pages/man7/namespaces.7.html)), what system resources a process can use ([cgroups](http://man7.org/linux/man-pages/man7/cgroups.7.html])), and what system calls a process can make ([seccomp](http://man7.org/linux/man-pages/man2/seccomp.2.html)) combined with other features such as enhanced access control ([SELinux](https://selinuxproject.org/page/Main_Page)). We use [container images](https://docs.docker.com/v17.09/engine/userguide/storagedriver/imagesandcontainers/#images-and-layers) (all the dependencies and files our application needs to run put together in layers), which we can bundle and store in image repositories to use to start containers (run a process using the files from the aforementioned container image (image) tar file in an environment with the isolation described above).


If you just finished reading the above and want to get a little depper into some of the parts of containers I just name-dropped please have a look see at [What even is a container: namespaces and cgroups](https://jvns.ca/blog/2016/10/10/what-even-is-a-container/). 


If you want a technical deep-dive into containers and container runtimes getting into the nitty-gritty, the fabulous 4 part series [Container Runtimes](https://www.ianlewis.org/en/container-runtimes-part-1-introduction-container-r) is the happy path for you.


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

## Places to go and things to see in the Future

### Possible Next Step
[Building a Helm Chart from Kubernetes yaml files](https://www.ibm.com/blogs/bluemix/2017/10/quick-example-helm-chart-for-kubernetes/)

### IBM Guidance on Containers and ICP Multi-Arch Process
- [IBM Guidance on running docker containers on IBM Z PDF](http://public.dhe.ibm.com/software/dw/linux390/docu/l177vd00.pdf)</br>

- [IBM Cloud Private Enablement Guide for ISV](https://developer.ibm.com/linuxonpower/ibm-cloud-private-on-power/isv-guide/)

## Shoutout to Mkdocs
I made this site with [mkdocs](https://www.mkdocs.org) using the [material](https://squidfunk.github.io/mkdocs-material/) theme.
