## Buildx: Seamless multi-arch builds are in your future

Buildx [https://github.com/docker/buildx] has become a part of stable Docker builds with `Docker CE 19.03` as an experimental feature. 

Since we have already enabled experimental features if our docker version is 19.03 or greater, we are ready to use buildx. We have already built are images above using a script. Let's see what the future holds...

First, we will create a new builder:
```
 docker buildx create --name multi-arch
```
Next, we will set this to our active builder:
```
docker buildx use multi-arch
```
Then, we will bootstrap it. At this point it will look for the supported architectures on our system using qemu and list them for us.
```
docker buildx inspect --bootstrap
```
Finally, we can see our current builders with
```
docker buildx ls
```

Here is how this all looks from my mac:

![Buildx Mac Setup](images/buildx_setup.png)

Notice, that the 2 architectures we want to use (s390x and amd64) are both supported on my system. This is because the qemu emulation is set up for s390x, arm (multiple versions), and ppc64le and my host platform is amd64 (in this case). This will work on any machine once its set up: either out-of-the-box with docker desktop for mac or windows or after you enable qemu on your linux box like we did above with the `gmoney23/binfmt` image.

Now, we can create a multi-architecture image for the two architectures (and more if desired) in one command
```
docker buildx build --platform linux/amd64,linux/s390x -t gmoney23/buildx-hello-node:1.0 node-web-app --push
```
![Buildx Hello](images/buildx-build-hello-node.png)

We can look at our newly pushed image to verify with:

```
docker run mplatform/mquery gmoney23/buildx-hello-node:1.0`
```
![mplatform buildx hello node](images/mplatform-buildx-hello-node.png)

To see the full manifest list we can inspect it with
```
docker manifest inspect gmoney23/buildx-hello-node:1.0
```

![manifest buildx hello node](images/manifest-buildx-hello-node.png)

Buildx isn't just limited to multi-arch builds with statics, it can also register remote builders to build images on those machines. Again, if you want to check it out see the [buildx github](https://github.com/docker/buildx). Also, if you want to see a walkthrough on buildx with arm see [Building Multi-Arch Images for Arm and x86 with Docker Desktop](https://engineering.docker.com/2019/04/multi-arch-images/).

We can use buildx to simplify the multi-arch process even further by bringing our build pipeline together in one place and allowing us to concurrently construct images for all arches that we can use in our manifest lists to "create" multi-arch images in one command.

Now, it's time to use the multi-arch images in Kubernetes!

Hearing `Kubernetes` fills us with determination...
## [Part 5: Now, it's time to get these images into Kubernetes](5-Deploy-to-Kubernetes.md)


### OPTIONAL [Most Users Should Skip]: [Overview of Process the Manual Way Building on Separate Machines](4-Multiarch-manual-addendum.md)

**This optional path is a Manual collection of tasks to build images in more depth if you want more detail. This is purely for educational purposes if something in the script didn't make sense or you want further material and not part of the main path.
