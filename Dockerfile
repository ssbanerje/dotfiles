FROM ubuntu:latest

MAINTAINER Subho Sankar Banerjee ssbanerje@gmail.com
LABEL org.opencontainers.image.title Dotfiles
LABEL org.opencontainers.image.source https://github.com/ssbanerje/dotfiles

ARG user=dotuser
ARG uid=1000

# Setup prereq packages
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo python3 python3-yaml python3-distro python3-jinja2 && \
    adduser --disabled-password --gecos "" --uid ${uid} ${user} && \
    groupadd docker && \
    usermod -aG docker ${user} && \
    echo "%${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apt-get clean && rm -rf rm -rf /var/lib/apt/lists/*

# Setup dotfiles
USER ${user}
ENV DEBIAN_FRONTEND=noninteractive
COPY . /home/${user}/.dotfiles
RUN cd /home/${user}/.dotfiles && \
    ./install_profile ubuntu && \
    git remote set-url origin git@github.com:ssbanerje/dotfiles && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Take command from user
CMD []
