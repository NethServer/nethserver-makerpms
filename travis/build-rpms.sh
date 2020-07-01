set -e

if [[ "${NSVER}" == 6 ]]; then
    echo "[NOTICE] Skip RPMs build for ns6"
    exit 0
fi

docker run -ti --name makerpms ${EVARS} \
    --hostname b${TRAVIS_BUILD_NUMBER}.nethserver.org \
    --volume $PWD:/srv/makerpms/src:ro ${DOCKER_IMAGE} \
    makerpms-travis *.spec

docker commit makerpms nethserver/build

docker run -ti ${EVARS} \
    -e SECRET \
    -e SECRET_URL \
    -e AUTOBUILD_SECRET \
    -e AUTOBUILD_SECRET_URL \
    nethserver/build uploadrpms-travis
