FROM alpine:3.13

ARG ANSIBLE_VERSION=2.10
ARG SOPS_VERSION=3.7.1
ARG STEP_VERSION=0.15.16
ARG TASK_VERSION=3.4.2
ARG TERRAFORM_VERSION=0.14.8
ARG VAULT_VERSION=1.7.3
ARG CONSUL_VERSION=1.10.0

WORKDIR /

ENV DEBIAN_FRONTEND=noninteractive
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install build deps
RUN apk --update --no-cache add --virtual .build-dep \
    bash \
    build-base \
    gettext \
    libffi-dev \
    libintl \
    openssl-dev \
    python3-dev \
    unzip && \
    # Install deps
    apk --update --no-cache add \
    apache2-utils \
    ca-certificates \
    curl \
    git \
    git-crypt \
    gnupg \
    jq \
    openssh-client \
    openssl \
    python3 \
    py3-pip \
    rsync \
    shellcheck \
    sshpass \
    sudo \
    yq \
    nomad

# Install required binaries
RUN \
    # ansible
    pip3 install --upgrade pip cffi && \
    pip3 install ansible==${ANSIBLE_VERSION} && \
    pip3 install mitogen ansible-lint jmespath netaddr && \
    # ansible collections
    ansible-galaxy collection install "community.general" && \    
    ansible-galaxy install "brianshumate.consul" && \
    ansible-galaxy install "brianshumate.vault" && \
    ansible-galaxy install "brianshumate.nomad" && \
    ansible-galaxy install "geerlingguy.docker" && \
    ansible-galaxy install "kibatic.traefik"
RUN \
    # envsubst
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \   
    # sops
    curl -sL -o sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux && \
    mv sops /usr/bin && chmod +x /usr/bin/sops && \
    # step
    curl -sL -o step.tar.gz https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_linux_${STEP_VERSION}_amd64.tar.gz && \
    tar -xzvf step.tar.gz -C /usr/bin --strip-components=2 step_${STEP_VERSION}/bin/step && \
    rm -rf step.tar.gz step_${STEP_VERSION} && \
    chmod +x /usr/bin/step && \    
    # task
    curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    rm -rf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task && \
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
    # consul
    curl -sL -o consul_${CONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip  && \
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip && \
    mv consul /usr/bin/consul && \
    chmod +x /usr/bin/consul && \
    rm -rf consul_${CONSUL_VERSION}_linux_amd64.zip
    
# Cleanup
RUN rm -rf /var/cache/apk/*

CMD bash