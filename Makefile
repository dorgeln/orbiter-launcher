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



devel:
	pip install doit jupyter-repo2docker

run:
	docker image rm --force orbiter
	jupyter-repo2docker --debug  --user-name ${USER} --user-id ${UID} -P --volume ${NOTEBOOK_DIR}:./notebooks --volume ${BOOK_DIR}:./book --volume /home/${USER}/.ssh:.ssh --image-name orbiter .

clean:
	-rm package.json  package-lock.json  poetry.lock  pyproject.toml core/alpine.pkg build/alpine.pkg deploy/alpine.pkg  build/package.json build/requirements.txt build/requirements-extra.txt deploy/requirements.txt

deps: 
	[ -f core/alpine.pkg ] || echo ${ALPINE_CORE} > core/alpine.pkg
	[ -f build/alpine.pkg ] || echo ${ALPINE_BUILD} > build/alpine.pkg
	[ -f deploy/alpine.pkg ] || echo ${ALPINE_DEPLOY} > deploy/alpine.pkg


	if [ ! -f build/package.json ]; then
		npm install --package-lock-only ${NPM_BUILD}
		cp package.json build/package.json
	fi

	if [ ! -f pyproject.toml ]; then 
		poetry init -n --python ${PYTHON_REQUIRED}
		sed -i 's/version = "0.1.0"/version = "${VERSION}"/g' pyproject.toml
		poetry config virtualenvs.path .env
		poetry config cache-dir .cache;poetry config virtualenvs.in-project true 
	fi


	if [ ! -f build/requirements.txt ]; then
		poetry add -v --lock ${PYTHON_BUILD}
		poetry export --without-hashes -f requirements.txt -o build/requirements.txt
	fi

	if [ ! -f build/requirements-extra.txt ]; then 
		poetry add -v --lock ${PYTHON_BUILDEXTRA}
		poetry export --without-hashes -f requirements.txt -o build/requirements-extra.txt
	fi

	if [ ! -f deploy/requirements.txt ]; then
		poetry add -v --lock ${PYTHON_DEPLOY}
		poetry export --without-hashes -f requirements.txt -o deploy/requirements.txt
	fi

build: deps
	docker image build --build-arg VERSION=${VERSION} --build-arg PYTHON_VERSION=${PYTHON_VERSION} --build-arg DOCKER_USER=${DOCKER_USER} --build-arg DOCKER_REPO=${DOCKER_REPO}  -t ${DOCKER_USER}/${DOCKER_REPO}:core -t ${DOCKER_USER}/${DOCKER_REPO}:core-${VERSION} core 
	docker image build --build-arg VERSION=${VERSION} --build-arg DOCKER_USER=${DOCKER_USER} --build-arg DOCKER_REPO=${DOCKER_REPO}  -t ${DOCKER_USER}/${DOCKER_REPO}:build -t ${DOCKER_USER}/${DOCKER_REPO}:build-${VERSION} build
	docker image build --build-arg VERSION=${VERSION} --build-arg DOCKER_USER=${DOCKER_USER} --build-arg DOCKER_REPO=${DOCKER_REPO}  -t ${DOCKER_USER}/${DOCKER_REPO}:latest -t ${DOCKER_USER}/${DOCKER_REPO}:${VERSION} deploy

push: build
	docker image push -a ${DOCKER_USER}/${DOCKER_REPO}