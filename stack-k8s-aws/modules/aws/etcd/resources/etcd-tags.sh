#!/bin/bash
set -e
set -o pipefail

update_tags() {
    # shellcheck disable=SC2086,SC2154
    /usr/bin/docker run \
        --volume /opt/update-tags.sh:/update-tags.sh:ro \
        --network=host \
        --env CLUSTER_NAME=${cluster_name} \
        --entrypoint=/update-tags.sh \
        ${awscli_image}
}

if [ "${update_tags}" == "true" ]; then
  update_tags
else
  exit 0
fi

exit 0
