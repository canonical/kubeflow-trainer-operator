#!/usr/bin/bash
RUNTIME_FOLDER=./src/training_runtimes/
for TPL in "${RUNTIME_FOLDER}"*.yaml; do
  IMAGE=$(yq '.spec.template.spec.replicatedJobs.[0].template.spec.template.spec.containers[0].image' "${TPL}")
  # set internal field separator to ":" and tokenize the image string
  IFS=':' read -ra SPLIT_IMAGE <<< "${IMAGE}"
  TAG="latest"
  # handle case in which image already has a tag
  if [ ${#SPLIT_IMAGE[@]} == 2 ]; then
    TAG=${SPLIT_IMAGE[-1]}
  fi
  # handle implicit registry
  IFS='/' read -ra SPLIT_IMAGE <<< "${SPLIT_IMAGE[0]}"
  REGISTRY="docker.io"
  if [ "${SPLIT_IMAGE[0]}" == "ghcr.io" ]; then
    REGISTRY=${SPLIT_IMAGE[0]}
  else
    SPLIT_IMAGE=("${REGISTRY}" "${SPLIT_IMAGE[@]}" )
  fi
  # set internal field separator to "/" and join the image string plus tag
  IFS="/" FINAL_IMAGE="${SPLIT_IMAGE[*]:0:${#SPLIT_IMAGE[@]}}:${TAG}"
  echo "Pulling ${FINAL_IMAGE}"
  # explanation of this command can be found in Canonical K8s image management doc
  # https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/image-management/
  # sudo /snap/k8s/current/bin/ctr --namespace k8s.io image pull "${FINAL_IMAGE}" > /dev/null 2>&1
done