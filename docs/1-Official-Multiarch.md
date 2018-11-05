# 1. Getting Official with MultiArch Images

This section goes through the official docker repositories for building images and what multi-architecture images are and how to spot them.

## Official Repositories
Docker [Official Repositories](https://docs.docker.com/docker-hub/official_repos/) are a special set of docker repositories on DockerHub that follow dockerfile best practices and regular security scans to allow them to serve as building blocks for your applications. These are the images to build your applications on top of.[Docker official images to use in builds](https://hub.docker.com/explore/) We will specifically be looking at building Node.js and Go applications so we will use the [Node.js Official Docker Image](https://hub.docker.com/_/node/) and the [Golang Official Docker Image](https://hub.docker.com/_/golang/). These images are multi-arch which means they support multiple architectures. All official images are [multi-arch] (https://blog.docker.com/2017/09/docker-official-images-now-multi-platform/). However, we want to know if these images support both s390x and x86. How do we know? If we look at the supported architectures under Quick reference we can see both images support both the x86 [amd64] and LINUXONE/z [s390x] architectures for the linux os :)
![docker golang architectures](../images/docker_golang.png)
**This means that if I run docker pull node on z, it will pull me the s390x image. Simalarly, if I run `docker pull node` on x86, it will pull me the x86 image.** Thus, once the image is built and set up as multi-arch the difference is abstracted away for applications using the image (such as a node application built using the Node.js official image as the base) **[i.e. `FROM node` works on both x86 and s390x].**

## How do Multi-Arch Images Work?
A Multi-Arch consists of a [manifest list](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list). This manifest list links its image i.e. [Node.js Official Docker Image](https://hub.docker.com/_/node/) to the image manifests of the docker images for the different architectures i.e. [s390x node image]((https://hub.docker.com/r/s390x/node/), [amd64 node image](https://hub.docker.com/r/amd64/node/), etc. This is how the magic happens so that instead of having to call the image for each architecture I can just pull node and it gives me the correct architecture image. Nevertheless, their are official repositories that hold the official images for each architecture which are where you can find the specific images linked to in the official image.

For z, we have:
[Official s390x images](https://hub.docker.com/u/s390x/)
such as the [s390x node](https://hub.docker.com/r/s390x/node/) and [s390x golang](https://hub.docker.com/r/s390x/golang/) images.

For x86, we have official [amd64 images](https://hub.docker.com/u/amd64/) such as the [amd64 node](https://hub.docker.com/r/amd64/node/) and [amd64 golang](https://hub.docker.com/r/amd64/golang/) images

Other architectures such as [Power](https://hub.docker.com/u/ppc64le/) and [arm32](https://hub.docker.com/u/arm32v7/) have their own repositories as well.

## Checking Image Architecture
Many times you will want to find if an image supports your archtitecture. If it doesn't and you try to run it you can get a nasty little error `standard_init_linux.go:185: exec user process caused "exec format error"` that stops are container from working. In hopes to avoid that trouble once we've already spent the time to pull the image and try to run it, here are the best ways to check images for architecture.
1. If the image exists on your system use docker inspect.
 i.e. `docker inspect busybox | grep "Architecture"`
        "Architecture": "amd64"
  **But what if the image isn't on your system?**

  `docker inspect alpine | grep "Architecture"`
        Error: No such object: alpine
  In order to fix this you would have to pull the image and then inspect it.
  i.e. `docker pull alpine` and then `docker inspect alpine | grep "Architecture"`
            "Architecture": "amd64"
  The problem with this is that you would potentially have to download some large images just to check if they are for your architecture which is time-consuming and a waste of space.
2. If the image isn't on your system, use the mplatform/mquery docker image i.e. `docker run --rm mplatform/mquery ibmcom/icp-nodejs-sample`
        Image: ibmcom/icp-nodejs-sample
        * Manifest List: Yes
        * Supported platforms:
        - linux/amd64
        - linux/ppc64le
        - linux/s390x
This image is "A simple utility and backend for querying Docker v2 API-supporting registry images and reporting on *manifest list* multi-platform image support" which tells us which architectures a given image supports by checking its manifest list [mquery project github page](https://github.com/estesp/mquery). If it is an image with no manifest list it will tell us that instead and which arch it supports.

  `docker run --rm mplatform/mquery s390x/node`
        Image: s390x/node
         * Manifest List: No
         * Supports: s390x/linux
Note: You can also use the mainfest-tool itself and docker manifest inspect to do this but the manifest-tool needs to be installed first and gives more verbose output and the docker manifest inspect command doesn't work for all supported registries yet as it continues to be improved and needs to be enabled (*it's currently experimental*). Thus, using the mquery image is generally better.

Next up, we will build some Node.js docker images and learn some Node.js docker best practices. [Node.js Docker Best Practices](2-Best-Practice-Nodejs.md)
