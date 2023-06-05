# ==============================================================================
# Devimage
# ==============================================================================

FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# ==============================================================================
# System Dependencies
#
# NOTE: Deps are installed here first because they are less likely to require
# updates at the same frequency in which languages/tools may require updates and
# we want to take advantage of layer caching where possible.
# ==============================================================================

# Add GitHub CLI repository
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install common dependencies
RUN apt-get update && apt-get -y install --no-install-recommends \
    gh gnupg direnv \
    libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg8-dev libgif-dev \
    && apt-get clean

# ==============================================================================
# Repo Dependencies (languages/libs/etc.)
# ==============================================================================

# install language deps
COPY ./scripts/install-language-deps.sh /tmp/scripts/install-language-deps.sh
RUN /tmp/scripts/install-language-deps.sh python ruby golang nodejs \
    && rm -rf /tmp/scripts/install-language-deps.sh

# install asdf
COPY ./scripts/install-asdf.sh /tmp/scripts/install-asdf.sh
RUN /tmp/scripts/install-asdf.sh \
    && rm -rf /tmp/scripts/install-asdf.sh

# use bash for subsequent commands so that we have access to asdf
SHELL ["/bin/bash", "-lc"]

# add/install languages
# =============================

ARG PYTHON_VERSION=3.11.2
RUN asdf plugin add python \
    && asdf install python ${PYTHON_VERSION} \
    && asdf global python ${PYTHON_VERSION}

ARG RUBY_VERSION=3.2.1
RUN asdf plugin add ruby \
    && asdf install ruby ${RUBY_VERSION} \
    && asdf global ruby ${RUBY_VERSION}

ARG GOLANG_VERSION=1.20.2
RUN asdf plugin add golang \
    && asdf install golang ${GOLANG_VERSION} \
    && asdf global golang ${GOLANG_VERSION}

ARG NODEJS_VERSION=18.5.0
RUN asdf plugin add nodejs \
    && asdf install nodejs ${NODEJS_VERSION} \
    && asdf global nodejs ${NODEJS_VERSION}

# add/install tools (depends on languages installation)
# =============================

ARG YARN_VERSION=1.22.11

RUN asdf plugin add yarn https://github.com/devtemplates/asdf-yarn \
    && asdf install yarn ${YARN_VERSION} \
    && asdf global yarn ${YARN_VERSION}

ARG TASK_VERSION=3.21.0
RUN asdf plugin-add task \
    && asdf install task ${TASK_VERSION} \
    && asdf global task ${TASK_VERSION}

RUN asdf plugin-add direnv \
    && asdf direnv setup --shell bash --version system \
    && asdf direnv setup --shell zsh --version system

# NOTE: Its unclear how much we should add to the box and how much should be
# left up to the individual user to install via their dotfiles:
# jq / fzf / lazygit / tmux / nano / vim /emacs

# Add asdf-helpers. This is a collection of functions that make it easier to
# to toggle to various language versions.
COPY ./scripts/add-asdf-helpers.sh /tmp/scripts/add-asdf-helpers.sh
RUN /tmp/scripts/add-asdf-helpers.sh \
    && rm -rf /tmp/scripts/add-asdf-helpers.sh

# Set the shell back to the default
SHELL ["/bin/sh", "-c"]

# ==============================================================================
# Configure for usage
# ==============================================================================

# While asdf and its corresponding data have been installed globally for all
# users, the global version for each language/tool has only been set for the
# root user. We need to ensure that the the .tool-versions is available for the
# devcontainer user, vscode.
RUN cp /root/.tool-versions /home/vscode/.tool-versions \
    && chown vscode:vscode /home/vscode/.tool-versions
