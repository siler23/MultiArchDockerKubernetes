# Kubernetes Multi-Arch with Go and Nodejs

This guide has 5 main parts
[1. Official Docker Repos and Multi-Arch Primer](docs/MultiArch.md)
[2. Build go docker images](docs/go.md)
[3. Build nodejs docker images](docs/Nodejs.md)
[4. Build multi-arch docker images](docs/build.md)
[5. Use these images in your kubernetes cluster](Kubernetes.md)

## Prerequisites
* Have up and running Kubernetes cluster
* Setup access to that cluster using kubectl
* Setup docker on your host machine

This Tutorial will start by looking at what Official Repositories are and how to build from them. Then spread light on how to tell if an app will run on your platform (architecture). Then, we will look at how best to build images for go and nodejs in docker with examples and then actually build these images with Multi-Architecture manifests. Finally, we will use these images or my pre-build images to deploy to a kubernetes cluster.

[Next: Official Docker Repos and Multi-Arch Primer](docs/MultiArch.md)
