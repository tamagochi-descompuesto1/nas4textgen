#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${ROOT_DIR}/release-assets"
PART_SIZE="${PART_SIZE:-1900m}"

mkdir -p "${OUT_DIR}"

PACKAGES=(
  "models/distil-gpt2/base|models_distil_gpt2_base"
  "models/distil-gpt2/nas|models_distil_gpt2_nas"
  "models/surrogate-models|models_surrogate_models"
  "results/models|results_models"
  "results/nas|results_nas"
  "results/surrogate-models|results_surrogate_models"
  "results/text-gen|results_text_gen"
)

MANIFEST="${OUT_DIR}/manifest.csv"
echo "package,part_file,size_bytes,sha256" > "${MANIFEST}"

package_dir() {
  local rel_path="$1"
  local package_name="$2"
  local abs_path="${ROOT_DIR}/${rel_path}"
  local prefix="${OUT_DIR}/${package_name}.tar.gz.part-"

  if [[ ! -d "${abs_path}" ]]; then
    echo "Skipping missing directory: ${rel_path}"
    return
  fi

  rm -f "${OUT_DIR}/${package_name}.tar.gz.part-"* "${OUT_DIR}/${package_name}.tar.gz.part-"*.sha256

  echo "Packaging ${rel_path} -> ${package_name}"
  tar -C "${ROOT_DIR}" -cf - "${rel_path}" | gzip -1 | split -d -a 3 -b "${PART_SIZE}" - "${prefix}"

  local part
  while IFS= read -r -d '' part; do
    local size
    local hash
    size="$(stat -c %s "${part}")"
    hash="$(sha256sum "${part}" | awk '{print $1}')"
    printf "%s,%s,%s,%s\n" "${package_name}" "$(basename "${part}")" "${size}" "${hash}" >> "${MANIFEST}"
    printf "%s  %s\n" "${hash}" "$(basename "${part}")" > "${part}.sha256"
  done < <(find "${OUT_DIR}" -maxdepth 1 -type f -name "${package_name}.tar.gz.part-*" ! -name "*.sha256" -print0 | sort -z)
}

for item in "${PACKAGES[@]}"; do
  rel_path="${item%%|*}"
  package_name="${item##*|}"
  package_dir "${rel_path}" "${package_name}"
done

cat <<EOF

Assets generated in:
  ${OUT_DIR}

Manifest:
  ${MANIFEST}

Suggested next step:
  Upload the generated parts to GitHub Releases.
EOF
