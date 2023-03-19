#!/bin/bash

# ##############################################################################
#
# install-asdf.sh
# Install and configure asdf for usage.
#
# Note: Non-interactive/Non-login shells will not have the ASDF initialization
#
# ##############################################################################

# Set the version and location to install ASDF
ASDF_VERSION="${1:-0.10.2}"
ASDF_DIR="/opt/asdf"
ASDF_DATA_DIR=/opt/asdf/data

# Clone the ASDF repository and set appropriate permissions
git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "v$ASDF_VERSION"
chmod -R a+rwX "$ASDF_DIR"

zsh_initialization=$(
    cat <<EOF
export ASDF_DIR=$ASDF_DIR
export ASDF_DATA_DIR=$ASDF_DATA_DIR

. $ASDF_DIR/asdf.sh
. $ASDF_DIR/completions/asdf.bash
EOF
)

# ##############################################################################
# bash config
# ##############################################################################

# Write ASDF initializations steps to /etc/profile.d/asdf.sh so that they are
# executed system-wide login shells.
echo "$zsh_initialization" >/etc/profile.d/asdf.sh

# Additionally, update the bashrc so that the ASDF initialization steps are
# executed for non-login shells.
echo ". /etc/profile.d/asdf.sh" >>/etc/bash.bashrc

# ##############################################################################
# zsh config
# ##############################################################################

# Write ASDF initializations steps to /etc/profile.d/asdf.sh so that they are
# executed system-wide login shells.
echo "$zsh_initialization" >/etc/zshrc.d/asdf.sh

# Additionally, update the bashrc so that the ASDF initialization steps are
# executed for non-login shells.
echo ". /etc/profile.d/asdf.sh" >>/etc/.zshenv
