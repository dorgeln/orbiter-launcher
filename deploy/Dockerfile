ARG DOCKER_USER
ARG DOCKER_REPO

FROM ${DOCKER_USER}/${DOCKER_REPO}:build as build
FROM ${DOCKER_USER}/${DOCKER_REPO}:core as deploy
ARG DOCKER_USER
ARG DOCKER_REPO
COPY --chown=${NB_USER} --from=build ${ENV_ROOT} ${ENV_ROOT}
COPY alpine.pkg alpine.pkg
RUN PKG=`cat alpine.pkg` && echo "Installing ${PKG}" &&  sudo apk add --no-cache ${PKG}
COPY --chown=${NB_USER} requirements.txt requirements.txt
RUN pip install -vv -r requirements.txt
RUN python -m bash_kernel.install
