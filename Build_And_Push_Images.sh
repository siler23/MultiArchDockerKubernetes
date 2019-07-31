#!/bin/bash -e

# Throw error if DOCKER_REPO not set by script
if [ -z ${DOCKER_REPO} ]
then
	echo -e "\nError: DOCKER_REPO is not set. Please set this to your Docker repo !!!\n"
  echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
  exit 1
fi

# Throw error if VERSION not set by script
if [ -z ${VERSION} ]
then
    echo -e "\nError: VERSION is not set. Version is the version your images will be tagged with. !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
    exit 1
fi

if [ -z ${IMAGE_PREPEND} ]
then
    echo -e "\nError:IMAGE_PREPEND is not set. Set this to what you want the image to be prepended with. This is so the names don't conflict with any of the current images in your Dockerhub repository. !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true or false> ./Build_And_Push_Images.sh"
    exit 1
fi

if [ -z ${LATEST} ]
then
    echo -e "\nError: LATEST is not set. Set this to true or false based on whether or not you want to also create and push a latest image !!!\n"
    echo -e "Usage:\n\tDOCKER_REPO=<my_docker_repo> VERSION=<version_number> IMAGE_PREPEND=<prepend_to_make_unique_image> LATEST=<true_or_false> ./Build_And_Push_Images.sh"
    exit 1
fi

export MAINDIR=${PWD}

IMAGES=("icp-nodejs-sample" "node-web-app" "outyet" "small-outyet" "smallest-outyet" "example-go-server" "href-counter")
ARCHES=("s390x" "amd64")

function buildImage {
  
  export IMAGE=$1
  export ARCH=$2

  cd ${MAINDIR}/${IMAGE}

  echo
  echo "Current Directory: ${PWD}"
  echo "Building Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}"
  echo

  docker build -t ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} --pull --platform=${ARCH} .

  if [ ${LATEST} = true ]
  then
    echo
    echo "Tagging Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} as latest"
    echo
    
    docker tag ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION} ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest
  fi
}

function pushImage {
  
  export IMAGE=$1
  export ARCH=$2

  cd ${MAINDIR}/${IMAGE}

  echo
  echo "Current Directory: ${PWD}"
  echo "Pushing Versioned Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}"
  echo

  docker push ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:${VERSION}
  
  if [ ${LATEST} = true ]
  then
    echo
    echo "Pushing Latest Image: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest"
    echo
    docker push ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${ARCH}:latest
  fi  
}

function addManifest {

  export IMAGE=$1

  echo
  echo "Creating Versioned Manifest List with ${ARCHES[@]} images named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}"
  echo

  declare -a MANIFEST_IMAGES
  for image_arch in "${ARCHES[@]}" 
  do
    MANIFEST_IMAGES+=("${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}-${image_arch}:${VERSION}")
  done

  docker manifest create ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION} ${MANIFEST_IMAGES[@]}
  unset MANIFEST_IMAGES
  echo
  echo "Pushing Versioned Manifest List with ${ARCHES[@]} images Named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}"
  echo

  docker manifest push -p ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:${VERSION}
  
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
    echo "Pushing Latest Manifest List with ${ARCHES[@]} images named: ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest"
    echo

    docker manifest push -p ${DOCKER_REPO}/${IMAGE_PREPEND}-${IMAGE}:latest

  fi
  
}

for image in "${IMAGES[@]}"
do
  for arch in "${ARCHES[@]}" 
  do
    buildImage ${image} ${arch}
    pushImage ${image} ${arch}
  done

  addManifest ${image}

done
