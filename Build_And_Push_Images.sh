#!/bin/bash -e

# Throw error if DOCKER_REPO not set
if [ -z "${DOCKER_REPO}" ]
then
	echo -e "\nError: DOCKER_REPO is not set. Please set this to your Docker repo !!!\n"
  echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
  exit 1
fi

# Throw error if VERSION not set
if [ -z "${VERSION}" ]
then
    echo -e "\nError: VERSION is not set. Version is the version your images will be tagged with. !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
    exit 1
fi

# Throw error if IMAGE_PREPEND is not set
if [ -z "${IMAGE_PREPEND}" ]
then
    echo -e "\nError:IMAGE_PREPEND is not set. Set this to what you want the image to be prepended with. This is so the names don't conflict with any of the current images in your Dockerhub repository. !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true or false> ./Build_And_Push_Images.sh"
    exit 1
fi

# Throw error if LATEST is not set
if [ -z "${LATEST}" ]
then
    echo -e "\nError: LATEST is not set. Set this to true or false based on whether or not you want to also create and push a latest image !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
    exit 1
fi

# Set the images to build (One image for each sample project)
IMAGES=("icp-nodejs-sample" "node-web-app" "outyet" "small-outyet" "smallest-outyet" "example-go-server" "href-counter")

# Set the architectures to build images for
ARCHES=("s390x" "amd64")

# Function to build an image by passing in image name and architecture
function buildImage {
  
  export IMAGE=$1
  export ARCH=$2

  # If no proxy variables are set, commence with regular build. If any proxy variables are set, build with proxy variables.
  if [ -z "${http_proxy}" ] && [ -z "${https_proxy}" ] && [ -z "${no_proxy}" ]
  then
    echo
    echo "Building Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}"
    echo
    # Build image by forcing pull of base image for the desired arch. Note: --platform is an experimental feature which needs to be enabled. 
    # ${IMAGE} is directory of build
    docker build -t ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} --pull --platform=${ARCH} "${IMAGE}"
  else
    # Build image with proxy settings 
    echo
    echo "Building Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} with proxy settings of http_proxy=$http_proxy, https_proxy=$https_proxy, no_proxy=$no_proxy"
    echo
    docker build -t ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} --pull --platform=${ARCH} --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy="$no_proxy" "${IMAGE}"
  fi

  # If desired, tag the versioned image as the new latest image 
  if [ ${LATEST} = true ]
  then
    echo
    echo "Tagging Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} as latest"
    echo
    
    docker tag ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest
  fi
}

# Function to push the built image by passing in image name and architecture
function pushImage {
  
  export IMAGE=$1
  export ARCH=$2

  echo
  echo "Pushing Versioned Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}"
  echo

  # Push the new version of the image that was just built
  docker push ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}
  
  # If desired, push the newest built version of the image as the latest image
  if [ ${LATEST} = true ]
  then
    echo
    echo "Pushing Latest Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest"
    echo
    docker push ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest
  fi  
}

# Function to create, annotate and push a manifest list to create a Multi-Architecture image with the individual images pushed for each architecture specified in the arches for the script.
function addManifest {

  export IMAGE=$1

  echo
  echo "Creating Versioned Manifest List with ${ARCHES[@]} images named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}"
  echo

  # Make array of all of the images to reference in the manifest list for this docker image.
  declare -a MANIFEST_IMAGES
  for image_arch in "${ARCHES[@]}" 
  do
    MANIFEST_IMAGES+=("${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${image_arch}:${VERSION}")
  done

  # Create manifest list
  docker manifest create ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION} ${MANIFEST_IMAGES[@]}
  unset MANIFEST_IMAGES
  
  # Annotate manifest list metadata with architecture and os of each image. Docker tries to get this information automatically 
  # but providing it here makes sure it is correct for the cases when it isn't able to correctly glean this information.
  # This is important becuase the docker daemon will use this metadatis to pull the right image for the given architecture it is running on.
  echo
  echo "Annotating Manifest List with ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest arches: ${ARCHES[@]} and linux os"
  echo
  
  for image_arch in "${ARCHES[@]}" 
  do
    docker manifest annotate ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION} ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${image_arch}:${VERSION} --os linux --arch ${image_arch}
  done

  # Push manifest list with -p (purge) option so that once the manifest is pushed it is elimated from the local memory. This allows future docker manifest create commands to start fresh.
  echo
  echo "Pushing Versioned Manifest List with ${ARCHES[@]} images Named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}"
  echo

  docker manifest push -p ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}
  
  # If desired, create, annotate, and push the latest manifest list to make the new versioned images the latest
  if [ ${LATEST} = true ]
  then

    declare -a MANIFEST_IMAGES
    for image_arch in "${ARCHES[@]}" 
    do
      MANIFEST_IMAGES+=("${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${image_arch}:latest")
    done

    echo
    echo "Creating Latest Manifest List with ${ARCHES[@]} images named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest"
    echo

    docker manifest create ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest ${MANIFEST_IMAGES[@]}
    unset MANIFEST_IMAGES

    echo
    echo "Annotating Manifest List with ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest arches: ${ARCHES[@]} and linux os"
    echo

    for image_arch in "${ARCHES[@]}" 
    do
      docker manifest annotate ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${image_arch}:latest --os linux --arch ${image_arch}
    done 

    echo
    echo "Pushing Latest Manifest List with ${ARCHES[@]} images named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest"
    echo

    docker manifest push -p ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest

  fi
  
}

# Call functions to build an image for each desired architecture, push it, create a manifest list, and push the manifest list
# to make each image multi-architecture for the architectures chosen with the ARCHES= command at the top of the script.
for image in "${IMAGES[@]}"
do
  for arch in "${ARCHES[@]}" 
  do
    buildImage ${image} ${arch}
    pushImage ${image} ${arch}
  done

  addManifest ${image}

done
