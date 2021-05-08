.ONESHELL:
SHELL := /bin/bash
USER := $(shell whoami)
UID := $(shell id -u)
NOTEBOOK_DIR := $(shell readlink -f notebooks)
BOOK_DIR := $(shell readlink -f book)

SHELL := /bin/bash
VERSION := 0.0.18
DOCKER_USER := dorgeln
DOCKER_REPO := orbiter
PYTHON_VERSION := 3.8.8
PYTHON_REQUIRED := ">=3.8,<3.9"
PYTHON_TAG := python-${PYTHON_VERSION}

NPM_BUILD := vega-lite vega-cli canvas configurable-http-proxy

ALPINE_CORE := sudo bash curl git git-lfs ttf-liberation nodejs npm gettext libffi libzmq sqlite-libs openblas openssl tar zlib ncurses bzip2 xz libffi pixman cairo pango openjpeg librsvg giflib libpng openblas-ilp64 lapack libxml2 zeromq libnsl libxslt libtirpc libjpeg-turbo tiff freetype libwebp libimagequant lcms2
ALPINE_BUILD := build-base alpine-sdk g++ expat-dev openssl-dev zlib-dev ncurses-dev bzip2-dev xz-dev sqlite-dev libffi-dev linux-headers readline-dev pixman-dev cairo-dev pango-dev openjpeg-dev librsvg-dev giflib-dev libpng-dev openblas-dev lapack-dev gfortran libxml2-dev zeromq-dev gnupg tar xz expat-dev gdbm-dev libnsl-dev libtirpc-dev pax-utils util-linux-dev xz-dev zlib-dev libjpeg-turbo-dev tiff-dev libwebp-dev libimagequant-dev lcms2-dev cargo libxml2-dev libxslt-dev boost-dev
ALPINE_DEPLOY :=  neofetch chromium-chromedriver

PYTHON_BUILD := Cython numpy pandas jupyterlab altair altair_saver nbgitpuller jupyter-server-proxy cysgp4 Pillow jupyterlab-spellchecker pyyaml toml matplotlib sshkernel jupyterlab-git asciinema cowsay lolcat doit black flit bash_kernel docker GitPython sphinx ablog pydata_sphinx_theme  sphinx_panels jupyter-book
PYTHON_BUILDEXTRA :=   jupyterlite ttygif nbdev # dvc jupyterlab-dvc
PYTHON_DEPLOY = vega_datasets

pyenv:
	pyenv install -s ${PYTHON_VERSION}
	pyenv local ${PYTHON_VERSION}
	pyenv global ${PYTHON_VERSION}
	python --version


devel:
	python -m pip install --upgrade pi
	pip install -U poetry -U jupyter-repo2docker -U invoke -U jupyter-repo2docker -U pyyaml

run:
	docker image rm --force orbiter
	jupyter-repo2docker --debug  --user-name ${USER} --user-id ${UID} -P --volume ${NOTEBOOK_DIR}:./notebooks --volume ${BOOK_DIR}:./book --volume /home/${USER}/.ssh:.ssh --image-name orbiter .

clean:
	inv clean

build:
	inv build
push:
	inv push
prune:
	inv prune