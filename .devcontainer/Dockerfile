FROM alpine:3.14

# default binary versions
ARG TASK_VERSION=3.6.0
ARG CONSUL_VERSION=1.10.0
ARG NOMAD_VERSION=1.1.1
ARG PACKER_VERSION=1.7.4
ARG TERRAFORM_VERSION=0.15.5
ARG VAULT_VERSION=1.8.1

ENV DEBIAN_FRONTEND=noninteractive \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV VAULT_VERSION="${VAULT_VERSION}"
ENV CONSUL_VERSION="${CONSUL_VERSION}"
ENV NOMAD_VERSION="${NOMAD_VERSION}"

# install persisted devcontainer dependencies
RUN apk --update --no-cache add \
    apache2-utils \
    bash \
    build-base \
    ca-certificates \
    curl \
    gettext \
    git \
    git-crypt \
    gnupg \
    jq \
    libffi-dev \
    libintl \
    nano \
    openssh-client \
    openssl \
    openssl-dev \
    python3 \
    python3-dev \
    py3-pip \
    rsync \
    shadow \
    shellcheck \
    sshpass \
    sudo \
    unzip \
    yaml-dev \
    yq \
    zsh

# install required binaries
RUN \
    # envsubst
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    # task
    curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    rm -rf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task && \
    # consul
    curl -sL -o consul_${CONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip  && \
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip && \
    mv consul /usr/bin/consul && \
    chmod +x /usr/bin/consul && \
    rm -rf consul_${CONSUL_VERSION}_linux_amd64.zip && \
    # packer
    curl -sL -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip  && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/bin/packer && \
    chmod +x /usr/bin/packer && \
    rm -rf packer_${PACKER_VERSION}_linux_amd64.zip && \
    # terraform
    curl -sL -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip  && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    # vault
    curl -sL -o vault_${VAULT_VERSION}_linux_amd64.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip  && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/bin/vault && \
    chmod +x /usr/bin/vault && \
    rm -rf vault_${VAULT_VERSION}_linux_amd64.zip && \
    # nomad
    apk --update --no-cache add nomad="${NOMAD_VERSION}-r0" \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

HEALTHCHECK NONE

# setup user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Setup shells
RUN usermod --shell /bin/zsh ${USERNAME}

COPY --chown=${USERNAME} .zshrc /home/${USERNAME}
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /home/${USERNAME}/.oh-my-zsh &> /dev/null && \
    rm -rf /home/${USERNAME}/.oh-my-zsh/.git && \
    chown -R ${USERNAME}:${USER_GID} /home/${USERNAME}/.oh-my-zsh && \
    chmod -R 700 /home/${USERNAME}/.oh-my-zsh

# cleanup
RUN rm -rf /var/cache/apk/*

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# install pip/ansible dependencies
COPY pip-requirements.txt ansible-requirements.yml /tmp/
RUN pip3 install --requirement /tmp/pip-requirements.txt
RUN .local/bin/ansible-galaxy install -r /tmp/ansible-requirements.yml

CMD ["/bin/zsh"]
