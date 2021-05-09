from invoke import task
import os

hashes={}

@task
def version(c,version=None):
    if not version: 
        version = c.orbiter.version

    print (version)


@task
def clean(c):
    c.run("rm -f package.json package-lock.json base_devel/package.json")
    c.run("rm -f pyproject.toml poetry.lock base_devel/requirements*.txt base/requirements*.txt")
    c.run("rm -f core/alpine*.pkg base_devel/alpine*.pkg base/alpine*.pkg")


@task()
def prune(c):
    c.run("docker system prune -af")

@task(clean)
def build_core(c):
    with open(c.core.alpine.file, "w") as output:
        output.write(c.core.alpine.pkg+'\n')

    c.run("docker image build --build-arg VERSION={version} --build-arg ALPINE_VERSION={alpine_version} --build-arg PYTHON_VERSION={python_version} --build-arg DOCKER_USER={docker_user} --build-arg DOCKER_REPO={docker_repo}  -t {docker_user}/{docker_repo}:core -t {docker_user}/{docker_repo}:core-{version} core | tee build-core.log".format(
        version=c.version, python_version=c.python.version, alpine_version=c.alpine.version, docker_user=c.docker.user, docker_repo=c.docker.repo))


@task(build_core)
def build_base_devel(c):
    with open(c.base_devel.alpine.file, "w") as output:
        output.write(c.base_devel.alpine.pkg+'\n')

    c.run("npm install - -package-lock-only {npm_pkg} && cp package.json {npm_file}".format(
        npm_pkg=c.base_devel.npm.pkg, npm_file=c.base_devel.npm.file))

    c.run("poetry init -n --python '{python_required}'".format(python_required=c.python.required))

    c.run("poetry config virtualenvs.path .env")
    c.run("poetry config cache-dir .cache")
    c.run("poetry config virtualenvs.in-project true")

    c.run("poetry add -v --lock {python_pkg}".format(python_pkg=c.base_devel.python.pkg))
    c.run("poetry export --without-hashes -f requirements.txt -o {python_file}".format(python_file=c.base_devel.python.file))

    c.run("docker image build --build-arg PYTHON_VERSION={python_version} --build-arg DOCKER_USER={docker_user} --build-arg DOCKER_REPO={docker_repo}  -t {docker_user}/{docker_repo}:base-devel -t {docker_user}/{docker_repo}:base-devel-{version} base-devel | tee build-base_devel.log".format(
        version=c.version, python_version=c.python.version, docker_user=c.docker.user, docker_repo=c.docker.repo))


@task(build_base_devel)
def build_base(c):
    with open(c.base.alpine.file, "w") as output:
        output.write(c.base.alpine.pkg+'\n')

    c.run("poetry add -v --lock {python_pkg}".format(python_pkg=c.base.python.pkg))
    c.run("poetry export --without-hashes -f requirements.txt -o {python_file}".format(python_file=c.base.python.file))

    c.run("docker image build --build-arg DOCKER_USER={docker_user} --build-arg DOCKER_REPO={docker_repo}  -t {docker_user}/{docker_repo}:base-{version} -t {docker_user}/{docker_repo}:base base | tee build-base.log ".format(
        version=c.version, docker_user=c.docker.user, docker_repo=c.docker.repo))


@task(build_base_devel)
def build_full_devel(c):
    with open(c.full_devel.alpine.file, "w") as output:
        output.write(c.full_devel.alpine.pkg+'\n')

    c.run(
        "poetry add -v --lock {python_pkg}".format(python_pkg=c.full_devel.python.pkg))
    c.run("poetry export --without-hashes -f requirements.txt -o {python_file}".format(
        python_file=c.full_devel.python.file))

    c.run("docker image build --build-arg PYTHON_VERSION={python_version} --build-arg DOCKER_USER={docker_user} --build-arg DOCKER_REPO={docker_repo}  -t {docker_user}/{docker_repo}:full-devel -t {docker_user}/{docker_repo}:full-devel-{version} full-devel | tee build-full_devel.log".format(
        version=c.version, python_version=c.python.version, docker_user=c.docker.user, docker_repo=c.docker.repo))


@task(build_full_devel)
def build_full(c):
    with open(c.full.alpine.file, "w") as output:
        output.write(c.full.alpine.pkg+'\n')

    c.run("docker image build --build-arg DOCKER_USER={docker_user} --build-arg DOCKER_REPO={docker_repo}  -t {docker_user}/{docker_repo}:full-{version} -t {docker_user}/{docker_repo}:full full | tee build-full.log ".format(
        version=c.version, docker_user=c.docker.user, docker_repo=c.docker.repo))


@task(build_base, build_full)
def build(c):
    print("Building images")


@task(build)
def push(c):
    c.run("docker image push -a {docker_user}/{docker_repo}".format(docker_user=c.docker.user, docker_repo=c.docker.repo))
