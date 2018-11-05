# Kubernetes Multi-Arch with Go and Nodejs

This guide has 5 main parts
1. [Official Docker Repos and Multi-Arch Primer](docs/1-Official-Multiarch.md)
2. [Build best practice nodejs docker images](docs/2-Best-Practice-Nodejs.md)
3. [Build best practice go docker images](docs/3-Best-Practice-go.md)
4. [Build multi-arch docker images](docs/4-Build-MultiArch.md)
5. [Deploy these images to your kubernetes cluster](docs/5-Deploy-to-Kubernetes.md)

## Prerequisites
* Have an up and running Kubernetes cluster
* Setup access to that cluster using kubectl
* Setup docker on your host machine

This Tutorial will start by looking at what Official Repositories are and how to build from them. Then, it will spread light on how to tell if an app will run on your platform (architecture). Next, we will look at how best to build images for go and nodejs in docker with examples and then actually build these images with Multi-Architecture manifests. Finally, we will use these images or my pre-build images to deploy to a kubernetes cluster.

[Next: Official Docker Repos and Multi-Arch Primer](docs/1-Official-Multiarch.md)
