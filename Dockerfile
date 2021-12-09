FROM ubuntu:20.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    ccache \
    ecj \
    fastjar \
    file \
    g++ \
    gawk \
    gettext \
    git \
    java-propose-classpath \
    libelf-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    python \
    python2.7-dev \
    python3 \
    python3-distutils \
    python3-setuptools \
    python3-dev \
    rsync \
    subversion \
    swig \
    time \
    unzip \
    wget \
    xsltproc zlib1g-dev \
 && useradd buildbot -m -k /dev/null -d /home/buildbot

USER buildbot

WORKDIR /home/buildbot
RUN git clone https://git.openwrt.org/openwrt/openwrt.git source \
 && cd /home/buildbot/source \
 && git checkout v19.07.7 \
 && make distclean \
 && ./scripts/feeds update -a \
 && ./scripts/feeds install -a

WORKDIR /home/buildbot