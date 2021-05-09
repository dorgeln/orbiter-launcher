ARG DOCKER_USER
ARG DOCKER_REPO

FROM ${DOCKER_USER}/${DOCKER_REPO}:core
ARG PYTHON_VERSION

COPY alpine.pkg alpine.pkg
RUN PKG=`cat alpine.pkg` && echo "Installing ${PKG}" &&  sudo apk add --no-cache ${PKG}

RUN echo "Installing Python-${PYTHON_VERSION}" && pyenv install -v ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION}
RUN pip install -U  pip -U setuptools -U wheel -U cython-setuptools

WORKDIR ${NPM_DIR}
COPY --chown=${NB_USER} package.json  ${NPM_DIR}/package.json
RUN npm install --verbose -dd --prefix ${NPM_DIR} && npm cache clean --force

WORKDIR ${PYENV_ROOT}
COPY --chown=${NB_USER} requirements.txt requirements.txt 
RUN pip install -v -r requirements.txt

RUN jupyter serverextension enable --sys-prefix nbgitpuller  && jupyter serverextension enable --sys-prefix jupyter_server_proxy && python -m sshkernel install --sys-prefix && python -m bash_kernel.install --sys-prefix  && jupyter serverextension enable --sys-prefix sshkernel && jupyter lab clean  -y && npm cache clean --force

WORKDIR ${HOME}
