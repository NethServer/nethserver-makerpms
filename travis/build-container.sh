set -e

docker build -t ${DOCKER_IMAGE} buildimage
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
docker push ${DOCKER_IMAGE}
if [[ "${NSLATEST}" == "${NSVER}" ]]; then
    docker tag ${DOCKER_IMAGE} nethserver/makerpms:latest
    docker push nethserver/makerpms:latest
fi
docker run -ti --name buildsys ${DOCKER_IMAGE} sudo yum install -y @buildsys-build
docker commit buildsys nethserver/makerpms:buildsys${NSVER}
docker push nethserver/makerpms:buildsys${NSVER}
docker logout
