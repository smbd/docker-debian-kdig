#!/bin/bash

DEBIAN_REL=bookworm
KNOT_VER=3.3.2
KNOT_REL=1

function usage () {
  echo "Usage: ${0} [-l] [-p]"
  echo "    -l: update latest tag"
  echo "    -p: push to dockerhub"
  echo "    -h: show this"
  exit 1
}

while getopts hlp OPT ; do
  case ${OPT} in
    "l") LATEST="true" ;;
    "p") PUSH="true" ;;
    "h") usage ;;
  esac
done

shift $((${OPTIND}-1))

function abort () {
   echo "$1" 1>&2
   exit 1
}

# delete old base image
docker rmi debian:${DEBIAN_REL}-slim

image_name=kdig
image_tag=${KNOT_VER}

# build
## PUSH: false
docker build --progress plain --platform linux/amd64,linux/arm64 -t smbd/${image_name}:${image_tag} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."
docker build --load -t smbd/${image_name}:${image_tag} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."

if [ "${LATEST}" == "true" ] ; then
  docker build --platform linux/amd64,linux/arm64 -t smbd/${image_name}:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."
  docker build --load -t smbd/${image_name}:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."
fi

if [ "${PUSH}" == "true" ] ; then
  docker build --push --platform linux/amd64,linux/arm64 -t smbd/${image_name}:${image_tag} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."
  if [ "${LATEST}" == "true" ] ; then
    docker build --push --platform linux/amd64,linux/arm64 -t smbd/${image_name}:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg KNOT_VER=${KNOT_VER} --build-arg KNOT_REL=${KNOT_REL} . || abort "docker build faild. abort."
  fi
fi
