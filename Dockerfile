FROM ubuntu:latest

MAINTAINER Subho Sankar Banerjee
LABEL maintainer "Subho Sankar Banerjee ssbanerje@gmail.com"
LABEL org.opencontainers.image.source https://github.com/ssbanerje/dotfiles

ARG user=dotuser
ARG uid=1000

# Setup prereq packages
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y sudo git python3-dev python3-yaml python3-pip python3-distro python3-jinja2 docker docker-compose && \
    echo "%${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    adduser --disabled-password --uid ${uid} ${user} && \
    addgroup ${user} docker

# Setup dotfiles
USER ${user}
RUN git clone --recursive https://github.com/ssbanerje/dotfiles.git /home/${user}/.dotfiles &&\
      cd $HOME/.dotfiles && \
      ./install_profile ubuntu && \
      sudo apt-get clean && rm -rf rm -rf /var/lib/apt-get/lists/*

# Take command from user
CMD []
