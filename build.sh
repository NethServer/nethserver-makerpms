#!/bin/env bash

function build_image()
{
    echo "Building $1 image..."
    if [[ "$1" != "makerpms" ]]; then
        tag="$1"
    fi
    tag+=7
    buildah build \
        --layers \
        --force-rm \
        --tag "$image:$tag" \
        --file container/Containerfile \
        --target "$1" \
        container
}

image=${IMAGE_REPO:-nethserver/makerpms}
if ! command -v buildah &> /dev/null; then
    echo "buildah could not be found, is needed for the script to run."
    exit 1
fi

declare -a targets=()
if [[ $# -gt 0 ]]; then
    targets+=("$@")
else
    targets+=("makerpms" "buildsys" "devtoolset")
fi

for var in "${targets[@]}"; do
    build_image "$var"
done
