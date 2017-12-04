#!/bin/bash

if [ -z $VERSION ]; then
  if [ "$1" = "push" ]; then
    VERSION=1.0.$BUILD_NUMBER
  else
    VERSION=latest
  fi
fi

echo "Building $VERSION"
docker build -t odoko/exhibitor:${VERSION} .
if [ "$1" = "push" ]; then
  echo "Pushing $VERSION..."
  docker push odoko/exhibitor:${VERSION}
fi
