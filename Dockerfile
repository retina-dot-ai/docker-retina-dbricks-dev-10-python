FROM retina/dbricks-dev-00:latest

MAINTAINER "Brad Ito" brad@retina.ai

ARG PYTHON_VERSION=3.7.4
ARG PYTHON_MINOR_VERSION=3.7

# install the latest python version
# https://tecadmin.net/install-python-3-7-on-ubuntu-linuxmint/
RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    wget \
    ca-certificates \
    build-essential checkinstall \
    libreadline-gplv2-dev \
    libncursesw5-dev libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev
RUN cd /usr/src \
  && wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
  && tar xzf Python-$PYTHON_VERSION.tgz
RUN cd /usr/src/Python-$PYTHON_VERSION \
  && ./configure --enable-optimizations \
  && make altinstall
RUN update-alternatives \
  --install /usr/bin/python \
  python /usr/local/bin/python$PYTHON_MINOR_VERSION 3
RUN update-alternatives \
  --install /usr/bin/pip \
  pip /usr/local/bin/pip$PYTHON_MINOR_VERSION 3
ENV PYSPARK_PYTHON=/usr/local/bin/python$PYTHON_MINOR_VERSION

# use pipenv to install python packages
RUN pip install --upgrade pip \
  && pip install pipenv

COPY Pipfile /tmp/Pipfile
COPY Pipfile.lock /tmp/Pipfile.lock
RUN cd /tmp \
  && pipenv install --verbose --system

# cleanup
RUN apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

