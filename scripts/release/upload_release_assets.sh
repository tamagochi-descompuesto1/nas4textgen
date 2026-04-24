#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <owner/repo>"
  exit 1
fi

REPO="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSET_DIR="${ROOT_DIR}/release-assets"

require_assets() {
  local pattern="$1"
  compgen -G "${ASSET_DIR}/${pattern}" > /dev/null
}

create_or_upload() {
  local tag="$1"
  shift

  if ! gh release view "${tag}" --repo "${REPO}" >/dev/null 2>&1; then
    gh release create "${tag}" --repo "${REPO}" --title "${tag}" --notes "Release assets for ${tag}"
  fi

  gh release upload "${tag}" --repo "${REPO}" "$@"
}

base_assets=("${ASSET_DIR}"/models_distil_gpt2_base.tar.gz.part-* "${ASSET_DIR}"/models_distil_gpt2_base.tar.gz.part-*.sha256)
nas_assets=("${ASSET_DIR}"/models_distil_gpt2_nas.tar.gz.part-* "${ASSET_DIR}"/models_distil_gpt2_nas.tar.gz.part-*.sha256)
surrogate_assets=(
  "${ASSET_DIR}"/models_surrogate_models.tar.gz.part-* "${ASSET_DIR}"/models_surrogate_models.tar.gz.part-*.sha256
  "${ASSET_DIR}"/results_surrogate_models.tar.gz.part-* "${ASSET_DIR}"/results_surrogate_models.tar.gz.part-*.sha256
)
results_models_assets=("${ASSET_DIR}"/results_models.tar.gz.part-* "${ASSET_DIR}"/results_models.tar.gz.part-*.sha256)
results_nas_assets=("${ASSET_DIR}"/results_nas.tar.gz.part-* "${ASSET_DIR}"/results_nas.tar.gz.part-*.sha256)
results_text_assets=("${ASSET_DIR}"/results_text_gen.tar.gz.part-* "${ASSET_DIR}"/results_text_gen.tar.gz.part-*.sha256)

shopt -s nullglob

if ((${#base_assets[@]})); then
  create_or_upload "v1.0-base-models" "${base_assets[@]}"
fi

if ((${#nas_assets[@]})); then
  create_or_upload "v1.0-nas-models" "${nas_assets[@]}"
fi

if ((${#surrogate_assets[@]})); then
  create_or_upload "v1.0-surrogate" "${surrogate_assets[@]}"
fi

if ((${#results_models_assets[@]})); then
  create_or_upload "v1.0-results-models" "${results_models_assets[@]}"
fi

if ((${#results_nas_assets[@]})); then
  create_or_upload "v1.0-results-nas" "${results_nas_assets[@]}"
fi

if ((${#results_text_assets[@]})); then
  create_or_upload "v1.0-results-textgen" "${results_text_assets[@]}"
fi

echo "Upload flow finished for ${REPO}"
