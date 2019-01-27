#!/usr/bin/env bash

set -euo pipefail

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
# autotools, automake, make are present in the trusty image
  sudo apt-get install -y \
    liblo7 \
    liblo-tools \
    liblo-dev \
    libncursesw5-dev
fi

exit 0
