# 4. Building your multi-arch images

This section goes through installing the manifest tool and building the multi-arch docker images.

Making multi-arch docker images

**For Image names look at manifest.yaml in each directory and name your image that**
i.e. for outyet the image is gmoney23/outyet so set image=outyet. You will need to change these for your purposes if you want to make your own images.
1.	Build image for all architectures and push to docker registry

a. Build and push image for s390x (Go onto an s390x linux instance, ssh in)



   i. Get your code onto the instance (i.e. download git files or git clone https://github.com/siler23/MultiArchMultiArchDockerICP.git)

   ii. Get to the directory with the code (cd MultiArchDockerICP)

   iii. Build the image using docker (i.e. docker build -t outyet-s390x .)

   iv. Docker login to your docker registry (i.e. docker login registry name) [only need to do once for all images]

   v. Tag your image for that registry if not already done in build (i.e. docker tag outyet-s390x gmoney23/outyet-s390x)

   vi. Docker push image (i.e. docker push gmoney23/outyet-s390x)

  Quick pattern for this:
        cd `Desired Directory`

        IMAGE=outyet
        ARCH=s390x
        VERSION=1.0
        REPO=gmoney23

`docker build -t ${REPO}/${IMAGE}-${ARCH}:${VERSION} .
docker tag ${REPO}/${IMAGE}-${ARCH}:${VERSION} ${REPO}/${IMAGE}-${ARCH}:latest
docker push ${REPO}/${IMAGE}-${ARCH}:${VERSION}
docker push ${REPO}/${IMAGE}-${ARCH}:latest`





  b. Build and push image for x86 (Go onto an x86 computer with docker, probably your workstation)

   i. Get your code onto the instance if not already there (i.e. git clone https://github.com/siler23/MultiArchDockerICP.git)

   ii. Get to the directory with the code and Dockerfile (cd MultiArchDockerICP)

   iii. Build the image using docker (i.e. docker build -t outyet-x86 .)

   iv. Docker login to your docker registry (i.e. docker login registry name)

   v. Tag your image for that registry if not already done in build (i.e. docker tag outyet-x86 gmoney23/outyet-x86)

   vi. Docker push image (i.e. docker push gmoney23/outyet-x86)

  Quick pattern for this: cd `Desired Directory`

              IMAGE=outyet
              ARCH=x86
              VERSION=1.0
              REPO=gmoney23

`docker build -t ${REPO}/${IMAGE}-${ARCH}:${VERSION} .
docker tag ${REPO}/${IMAGE}-${ARCH}:${VERSION} ${REPO}/${IMAGE}-${ARCH}:latest
docker push ${REPO}/${IMAGE}-${ARCH}:${VERSION}
docker push ${REPO}/${IMAGE}-${ARCH}:latest`

2.	Make manifest list to make a multi-architecture image out of that individual images your pushed. Basically, you are mapping both images to the same tag so that when someone asks for example docker pull gmoney23/outyet it will redirect to the correct image for your architecture automatically (i.e. if you are on s390x it will use layers from gmoney23/outyet-s390x or if you are on x86 it will use layers from gmoney23/outyet-x86) while using the same label (i.e. gmoney23/outyet). This makes it so users of the image don’t have to worry about using different tags for different archs so the dockerfiles can be the same for different applications across architectures (i.e. the same dockerfile can be used for a node application on z and x86 or a go application on z and x86).

## Install Manifest tool
If golang not yet installed, install here with package for your os/arch [here](https://golang.org/dl/)

Install manifest-tool here with package for your os/arch [here](https://github.com/estesp/manifest-tool/releases)

### After all s390x and amd64 images are pushed
#### Push versioned manifest first
`manifest-tool --username gmoney23 --password *** push from-spec smallest-outyet/vmanifest.yaml`
#### Then push latest manifest for current versioned
`manifest-tool --username gmoney23 --password *** push from-spec smallest-outyet/manifest.yaml`

## Docker Manifest: An experimental feature not ready for production
### Enabling manifest lists in Docker
docker manifest
docker manifest is only supported on a Docker cli with experimental cli features enabled

####	Need to enable experimental feature
If `~/.docker/config.json` exists:
`vim ~/.docker/config.json`
Add `"experimental": "enabled"` to config.json file

If `~/.docker/config.json` doesn’t exist
`cd ~
mkdir .docker
cd .docker
vim config.json`
`echo $'{\n    "experimental": "enabled"\n}' | sudo tee -a config.json;`


First docker login to your registry, then
`docker manifest create gmoney23/outyet gmoney23/outyet-s390x gmoney23/outyet-x86`
`docker manifest push gmoney23/outyet` (It takes a minute to push, be patient)

[Now, it's time to get these images into Kubernetes](5-Deploy-to-Kubernetes.md)
