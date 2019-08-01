# 4. Building your multi-arch images

This section goes through installing the manifest tool and building the multi-arch docker images.

## If Using Proxy
If using proxy, make sure you've read [0-ProxyPSA](0-ProxyPSA.md) and have set your http_proxy, https_proxy, and no_proxy variables for your environment as specified there. Also note that for all docker run commands add the -e for each of the proxy environment variables as specified in that 0-ProxyPSA document.

## Enabling Docker Experimental Features
We need to enable experimental features for both the docker client and server in order to use the `docker manifest` command and `--platform` tags respectively. In order to do this please follow the steps below for your operating system.

IMPORTANT: PLEASE USE DOCKER 18.06 or later
If you don't have at least this version, please upgrade

![Upgrade Docker](../images/DockerUpdate.png)

Check with `docker version`
![Docker Version Output](../images/Docker_Version_Experimental_Check.PNG)
Under Client: If `Experimental: false` like in the above picture then you need to do the Client steps. If `Experimental: true` then you can skip Client steps.

Under Server: If `Experimental: false` like in the picture, you need to do Server steps. If `Experimental: true` then you can skip Server steps.

###### Linux
*Client*

`ls ~/.docker`

If `~/.docker/config.json` exists:

(Open config.json with favorite text editor)

`vim ~/.docker/config.json`
Add `"experimental": "enabled"` to config.json file
![End Result](../images/Linux_add_experimental.png)

If `~/.docker/config.json` doesn’t exist:

`mkdir .docker`

`echo $'{\n    "experimental": "enabled"\n}' | tee ~/.docker/config.json`

Add `"experimental": "enabled"` to `config.json` file
![Client Enabled Result](../images/Linux_add_client_fresh.png)

*Server*

`sudo ls /etc/docker`

If `/etc/docker/daemon.json` exists:

(Open daemon.json with favorite text editor)

`sudo vim /etc/docker/daemon.json`
Add `"experimental": true` to `daemon.json` file

If `/etc/docker/daemon.json` doesn't exist:

`echo $'{\n    "experimental": true\n}' | sudo tee /etc/docker/daemon.json`
![Server Enabled Result](../images/Linux_add_server_experimental.png)

**Restart Docker to Pick Up Changes**

`sudo service docker restart`

Once docker is started check `docker version` again to see experimental set to true for both client and server.
![Docker Version Final Linux](../images/Docker_Version_Final_Mac.png)

###### Mac
Open the Preferences from the menu

![Open Settings](../images/open_preferences_docker_mac.png)

*Client*

Go to `Command Line` and click to Enable expermental features. Then, click `Apply and Restart`.

![Command Line Mac](../images/Command_Line_Mac.png)

*Server*

Go to `Docker Engine` and change false to true for experimental. Then, click`Apply & Restart`.

![Docker Engine Mac](../images/Docker_Engine_Mac.png)

Once docker is started check `docker version` again to see experimental set to true for both client and server.
![Docker Version Final Mac](../images/Docker_Version_Final_Mac.png)

###### Windows
In the Windows file explorer go to your users directory and see if .docker exists if so open that directory and edit it with your favorite text editor. Add `"experimental": "enabled"` to config.json file

If it doesn't exist, make a new folder called .docker and create a new file called config.json. Add "experimental: enabled" inside of brackets.

![End Result](../images/Enabling-experimental.PNG)

###### Check for Success
In the end check your docker version to see that the change persisted. Specifically, look for client's experimental section being marked `Experimental: True`.
![Docker Version Final Mac](../images/Docker_Version_Final_Mac.png)

## Cross-Architecture Docker

Normally, one can only run docker images compiled for their architecture. This means that in order to run an s390x image you would need an s390x server. Additionally, since building an s390x image in most cases requires running s390x binaries on your system, this also requires an s390x server. The same holds true for x86 (amd64), power (ppc64le), arm, etc. This limits the ability to build images that are available across all platforms. One way to overcome this limitation is by using [binfmt_misc](https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html) in conjunction with [qemu](https://www.qemu.org/) (quick emulation) running using [User-mode-emulation](https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/). Qemu dynamically translates the target architecture's instructions to the the host architecture's instruction set to enable binaries of a different architecture to run on a host system. Binfmt_misc comes in to enable the kernel to read the foreign architecture binary by ["directing"](https://lwn.net/Articles/679308/) the kernel to the correct qemu static binary to interpret the code.

In order to set this up to work with Docker and its underlying linux kernel we first need:

1. binfmt_misc registers the corresponding qemu-static binary for each architecture that has a static qemu image available [of course other than the native one; s390x in this case].

2. provide these qemu-static binaries to the system for the host architecture to all of the target architectures.

3. Persist this setting for future kernel calls to be used with Docker for each container it creates in their new sets of namespaces

We are able to achieve these 3 things by using the [multiarch/qemu-user-static](https://github.com/multiarch/qemu-user-static) github project. 
The implementation they have works for an amd64 host so I have made a separate image using the qemu-static binaries for the s390x host and posted that multi-arch image to `gmoney23/multiarch-qemu-user-static:4.0.0-5`

You can test this out by first running an image that is from a different platform then yours.

##### Linux / Windows
`docker pull --platform amd64 hello-world`

`docker run hello-world`

You should get an exec format error like so:
![Failure exec error](../images/exec_error_amd64_s390x.png)

Now, run the docker image to perform the aforementioned required 3 steps on either s390x of amd64:

`docker run --rm --privileged gmoney23/multiarch-qemu-user-static --reset -p yes`

Confirm the architecture with: `uname -m`

Confirm the image architecture with: `docker inspect -f '{{.Architecture}}' hello-world`

Finally, run the image successfully with the same command as before: `docker run hello-world`

![Run power with qemu](../images/qemu_s390x_run_amd64.png)

We can also see in the `hello-world` output the `amd64` architecture mentioned as achieved our goal of running amd64 (x86) images on `s390x`.

##### Mac
Docker for mac builds in this capability is built-in out of the box so we don't even have to set it up with an image run. We can see this trying the `s390x` (z) image for `hello-world` on our `amd64` (x86) mac:

`docker pull --platform ppc64le hello-world`

`docker run hello-world`

![Run s390x with qemu](../images/qemu_mac_s390x_hello-world.png)

This works successfully (without configuration needed) for mac if you are using the latest version of Docker for mac CE (19.0.3 or later). 

### Consequences of Cross-Architecture Docker

This enables us to not only run images but now also build them for different architectures from a given host architecture. This makes it possible to build s390x (z), power (ppc64le), arm, and amd64 images all from the hosts you have available. This enables developers to support more images as they may have clusters with only specific architectures supported which can help braoden the ecosystem for everyone.

Next, we will use either your amd64 or s390x host to build images for both architectures and use them to make multi-arch images that support both architectures for each of the applications we have visited in parts 2 and 3 of this tutorial.

## Making multi-arch docker images

In order to build all of the images for both amd64 (x86) and s390x (z) architectures we will use a simple script that I wrote to go through the steps of building each inidividual architecture image with both a versioned and latest tag. Then, it creates a manifest list for each image and pushes it up to form a multiarch image for each of the applications we have gone over. It is heavily commented so it should explain itself.

[Build and Push Images Script](Build_And_Push_Images.sh)

### Login to your Dockerhub Account

`docker login`

Enter your username and password when prompted:

![Docker Login Before Script](../images/docker_login_before_script.png)
### Run Script to build and Push Images

#### Without Proxy

The options are as follows:

`DOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh`

Sample Command with my docker repo of `gmoney23` please replace with your docker repo:

`DOCKER_REPO=gmoney23 VERSION=1.0 IMAGE_PREPEND=marchdockerlab LATEST=true ./Build_And_Push_Images.sh`

#### With Proxy

The options are as follows:

`DOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> http_proxy=<proxy_for_http_protocol> https_proxy=<proxy_for_https_protocol> no_proxy=<addresses_not_to_be_proxied> ./Build_And_Push_Images.sh`

Sample Command with my docker repo of `gmoney23` please replace with your docker repo:

`DOCKER_REPO=gmoney23 VERSION=1.0 IMAGE_PREPEND=marchdockerlab LATEST=true http_proxy=http://myproxy:8080 https_proxy=http://myproxy:8080 no_proxy="localhost, 127.0.0.1" ./Build_And_Push_Images.sh`

### [Part 5: Now, it's time to get these images into Kubernetes](5-Deploy-to-Kubernetes.md)

**Below is a Manual collection of tasks to build images in more depth if you want more detail. This is purely for educational purposes if something in the script didn't make sense or you want further material and not part of the main path to follow the main path click to go to [part 5](5-Deploy-to-Kubernetes.md)**

#### OPTIONAL [Most Users Should Skip]: Overview of Process the Manual Way Building on Separate Machines

### 1.	Build image for all architectures and push to docker registry.
First is the list of basic steps, then a pattern you can use with both the mac and command  prompt commands.

#### Basic Steps
  a. Build and push image for s390x (Go onto an s390x linux instance, ssh in)

    i. Get your code onto the instance (i.e. download git files onto the machine or git clone https://github.com/siler23/MultiArchMultiArchDockerICP.git)

    ii. Get to the directory with the code (cd MultiArchDockerICP)

    iii. Build the image using docker (docker build -t myrepo/outyet-s390x .)

    PROXY: add build args for PROXY using previously set variables or if not reset variables and then run (docker build -t myrepo/outyet-x86 --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy="$no_proxy" .)

    iv. Docker login to your docker registry (docker login registry_address) [only need to do once for each command prompt/terminal session on a machine]

    v. Docker push image (docker push myrepo/outyet-s390x)

  b. Build and push image for x86 (Go onto an x86 computer with docker, probably your workstation)

    i. Get your code onto the instance if not already there (i.e. git clone https://github.com/siler23/MultiArchDockerICP.git)

    ii. Get to the directory with the code and Dockerfile (cd MultiArchDockerICP)

    iii. Build the image using docker (docker build -t myrepo/outyet-x86 .)

    PROXY: add build args for PROXY using previously set variables or if not reset variables and then run (docker build -t myrepo/outyet-x86 --build-arg http_proxy=%http_proxy% --build-arg https_proxy=%https_proxy% --build-arg no_proxy="%no_proxy%" .)

    iv. Docker login to your docker registry (docker login registry_address)

    v. Docker push image (docker push myrepo/outyet-x86)

## 2.	Make manifest list
***You only need to do this from one computer which for ease of access should probably be your workstation computer rather than a server***

Make a manifest list (a multi-architecture image reference) out of that individual images your pushed. Basically, you are mapping both images to the same tag so that when someone asks for the image via `docker pull gmoney23/outyet` it will have a pointer to the correct image for your architecture automatically (i.e. if you are on s390x it will point to layers from gmoney23/outyet-s390x or if you are on x86 it will point to layers from gmoney23/outyet-x86) while using the same label (i.e. gmoney23/outyet). This makes it so users of the image don’t have to worry about using different tags for different archs so the Dockerfiles can be the same for different applications across architectures (i.e. the same Dockerfile can be used for a node application on z and x86 or a go application on z and x86).

## Docker Manifest: An experimental feature

### Recommended Option: Unless need added features, use this built-in command and skip the optional section. If need added features, do the OPTIONAL section marked OPTIONAL below.
***You only need to do this from one computer which for ease of access should probably be your workstation computer rather than a server***
### Enabling manifest lists in Docker
docker manifest
docker manifest is only supported on a Docker cli with experimental cli features enabled

First `docker login` to your registry

IF USING PROXY: make sure your http_proxy, https_proxy, and no_proxy our set ***if pushing to a repo outside of your internal network***.
#### Push versioned first

**Replace gmoney23 with your registry in the commands below**

`docker manifest create gmoney23/outyet:1.0 gmoney23/outyet-s390x:1.0 gmoney23/outyet-x86:1.0`

`docker manifest push -p gmoney23/outyet:1.0` (It takes a minute to push, be patient)

If you want to inspect your manifest, use `docker manifest inspect gmoney23/outyet:1.0`
#### Then push latest for current versioned

**Replace gmoney23 with your registry in the commands below**

`docker manifest create gmoney23/outyet gmoney23/outyet-s390x gmoney23/outyet-x86`

`docker manifest push -p gmoney23/outyet` (It takes a minute to push, be patient)
**-p is important so you can push new manifests later for latest tag (no version tag defaults to latest as in this example)**

If you want to inspect your manifest, use `docker manifest inspect gmoney23/outyet`

**But what if I already pushed a latest before and want to update it with my new latest version?**

For example, you just pushed version 2.0 of your app, you can update the existing manifest by using:

 `docker manifest create --amend gmoney23/outyet gmoney23/outyet-s390x gmoney23/outyet-x86`

  to replace the new latest manifest with the old one after you have already updated the latest individual images to the version 2.0 images.


***You can also make a pattern for all of this if you want to automate the process or just type it out for each image...***

Time to go to the last stage, unless you need that pesky manifest-tool.

### [Part 5: Now, it's time to get these images into Kubernetes](5-Deploy-to-Kubernetes.md)

#### OPTIONAL [Most Users Should Skip]: Install Manifest tool if need added features
The docker manifest command is experimental becuase while it does create manifests and push it doesn't have other features yet such as pushing manifest from files. If you want these extra features you can install the manifest tool here. If not, I would suggest just using the docker manifest command as its generally integrated better with docker. For example, once you docker login you don't need to enter username/password like you do with manifest-tool.

***You only need to do this from one computer which for ease of access should probably be your workstation computer rather than a server***

If golang not yet installed, install here with package for your os/arch [here](https://golang.org/dl/)

If git not yet installed, see instructions here for how to install for your os [Git install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

***If using proxy***, set git proxy settings. An example would be if you want to use proxy for all git push/pull set `git config --global http.proxy http://proxyUsername:proxyPassword@proxy.server.com:port
` replacing with your proxy values. For more different git proxy configurations for your specific needs so [this gist on using git with proxies](https://gist.github.com/evantoli/f8c23a37eb3558ab8765)

Install manifest-tool here with package for your os/arch [here](https://github.com/estesp/manifest-tool/releases)

#### After all s390x and amd64 images are pushed (Only do the do following if you haven't done with the docker manifest command)
***You only need to do this from one computer which for ease of access should probably be your workstation computer rather than a server***
##### Push versioned manifest first
First, you will update the yaml files in the given directory of the image you are trying to push (in this case outyet) as well as change into the directory. Then, switch my username/password in the following command for yours for the image repository you are pushing to and:

IF USING PROXY: make sure your http_proxy, https_proxy, and no_proxy are set if pushing to a repo outside of your internal network.

`manifest-tool --username gmoney23 --password *** push from-spec smallest-outyet/vmanifest.yaml`

##### Then push latest manifest for current versioned
`manifest-tool --username gmoney23 --password *** push from-spec smallest-outyet/manifest.yaml`


##### [Part 5: Now, it's time to get these images into Kubernetes](5-Deploy-to-Kubernetes.md)
