set -e

pushd buildimage/
docker build -f Dockerfile-${NSVER} -t ${IMAGE_REPO}:${NSVER} .
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
docker push ${IMAGE_REPO}:${NSVER}
if [[ "${NSLATEST}" == "${NSVER}" ]]; then
    docker tag ${IMAGE_REPO}:${NSVER} ${IMAGE_REPO}:latest
    docker push ${IMAGE_REPO}:latest
fi
docker run -ti --name buildsys ${IMAGE_REPO}:${NSVER} sudo yum --setopt=tsflags=nodocs install -y @buildsys-build
docker commit buildsys ${IMAGE_REPO}:buildsys${NSVER}
docker push ${IMAGE_REPO}:buildsys${NSVER}
if [[ "${NSVER}" == 7 ]]; then
    docker run -ti --name devtoolset ${IMAGE_REPO}:buildsys${NSVER} sudo yum --setopt=tsflags=nodocs install --enablerepo=ce-sclo-rh -y devtoolset-9-\*
    docker commit devtoolset ${IMAGE_REPO}:devtoolset${NSVER}
    docker push ${IMAGE_REPO}:devtoolset${NSVER}
fi
docker logout
popd