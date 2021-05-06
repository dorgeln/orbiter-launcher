ARG VERSION
ARG DOCKER_USER
ARG DOCKER_REPO

FROM alpine:3.13.5 as core

ARG VERSION
ARG PYTHON_VERSION
ARG DOCKER_USER
ARG DOCKER_REPO
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

LABEL maintainer="Andreas Trawöger <atrawog@dorgeln.org>" org.dorgeln.version=${VERSION} 

RUN adduser --disabled-password  -u ${NB_UID} -G users ${NB_USER} && \
    addgroup -g ${NB_UID}  ${NB_USER} && \
    adduser ${NB_USER} ${NB_USER} && \
    adduser ${NB_USER} wheel


ENV ENV_ROOT="/env" 
ENV PYENV_ROOT=${ENV_ROOT}/pyenv \
    NPM_DIR=${ENV_ROOT}/npm 
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${NPM_DIR}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN sed -i "s/^export PATH=/#export PATH=L/g" /etc/profile
RUN mkdir -p ${ENV_ROOT} ${NPM_DIR} && chown -R ${NB_USER}.${NB_GID} ${ENV_ROOT}

ENV PYTHONUNBUFFERED=true \
    PYTHONDONTWRITEBYTECODE=true \
    PIP_NO_CACHE_DIR=true \
    PIP_DISABLE_PIP_VERSION_CHECK=true \
    PIP_DEFAULT_TIMEOUT=180 \
    NODE_PATH=${NPM_DIR}/node_modules \
    NPM_CONFIG_GLOBALCONFIG=${NPM_DIR}/npmrc \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    SHELL=/bin/bash \
    NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    JUPYTER_ENABLE_LAB=yes \
    PYTHON_VERSION=${PYTHON_VERSION} \
    DOCKER_USER=${DOCKER_USER} \
    DOCKER_REPO=${DOCKER_REPO} \
    VERSION=${VERSION} \
    USER=${NB_USER} \
    HOME=/home/${NB_USER} \
    REPO_DIR=/home/${NB_USER} \
    XDG_CACHE_HOME=/home/${NB_USER}/.cache \
    MAKE_OPTS="-j8" \
    CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-computed-gotos" \
    NPY_USE_BLAS_ILP64=1 \
    MAX_CONCURRENCY=8

WORKDIR ${HOME}

COPY alpine.pkg alpine.pkg
RUN PKG=`cat alpine.pkg` && echo "Installing ${PKG}" &&  apk add --no-cache ${PKG}
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && chmod 0440 /etc/sudoers.d/wheel

USER ${NB_USER}

RUN ln -s ${NODE_PATH}  ${HOME}/node_modules
RUN curl https://pyenv.run | bash

COPY entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
EXPOSE 8888

