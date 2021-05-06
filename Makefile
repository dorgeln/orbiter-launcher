.ONESHELL:
SHELL := /bin/bash
USER := $(shell whoami)
UID := $(shell id -u)
NOTEBOOK_DIR := $(shell readlink -f notebooks)
BOOK_DIR := $(shell readlink -f book)

devel:
	pip install jupyter-repo2docker

run:
	docker image rm --force orbiter
	jupyter-repo2docker --debug  --user-name ${USER} --user-id ${UID} -P --volume ${NOTEBOOK_DIR}:./notebooks --volume ${BOOK_DIR}:./book --volume /home/${USER}/.ssh:.ssh --image-name orbiter .
