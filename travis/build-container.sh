set -e

pushd buildimage/
docker build -f Dockerfile-${NSVER} -t ${DOCKER_IMAGE} .
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
docker push ${DOCKER_IMAGE}
if [[ "${NSLATEST}" == "${NSVER}" ]]; then
    docker tag ${DOCKER_IMAGE} nethserver/makerpms:latest
    docker push nethserver/makerpms:latest
fi
docker run -ti --name buildsys ${DOCKER_IMAGE} sudo yum --setopt=tsflags=nodocs install -y @buildsys-build
docker commit buildsys nethserver/makerpms:buildsys${NSVER}
docker push nethserver/makerpms:buildsys${NSVER}
if [[ "${NSVER}" == 7 ]]; then
    docker run -ti --name devtoolset nethserver/makerpms:buildsys${NSVER} sudo yum --setopt=tsflags=nodocs install --enablerepo=ce-sclo-rh -y devtoolset-9-\*
    docker commit devtoolset nethserver/makerpms:devtoolset${NSVER}
    docker push nethserver/makerpms:devtoolset${NSVER}
fi
docker logout
popd
