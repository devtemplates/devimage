#!/bin/bash

# ##############################################################################
#
# asdf-init.sh
#
# Function to load asdf and install a specific version of a language if it is
# not already installed.
#
# ##############################################################################

# python dependencies - https://github.com/pyenv/pyenv/wiki#suggested-build-environment
if [[ "$*" == *"python"* ]]; then
    apt-get -y install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
fi

# ruby dependencies - https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
if [[ "$*" == *"ruby"* ]]; then
    apt-get -y install --no-install-recommends autoconf bison patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
fi

# golang dependencies - https://github.com/kennyp/asdf-golang
if [[ "$*" == *"golang"* ]]; then
    apt-get -y install --no-install-recommends coreutils
fi

if [[ "$*" == *"nodejs"* ]]; then
    echo "no additional deps required"
fi

# Clean up downloaded package files
apt-get clean
