# Releases and Artifacts

This project distributes its heavy artifacts through `GitHub Releases`, not through `Git LFS`.

## What Gets Published in Releases

- Base `DistilGPT2` checkpoints
- Trained NAS models
- Surrogate models
- Outputs from `results/models`
- Outputs from `results/nas`
- Outputs from `results/surrogate-models`
- Outputs from `results/text-gen`

## What Does Not Get Published

- `datasets/`

Datasets were removed from the local project tree to save disk space and because they are not required for distributing the main research outputs.

## How Assets Are Packaged

The script [scripts/release/package_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/package_release_assets.sh:1) packages heavy artifacts into `tar.gz` archives split into `1900 MiB` chunks, keeping each file below the `2 GiB` GitHub Releases asset limit.

Each package produces:

- `.part-*` files
- one `.sha256` file per chunk
- a `manifest.csv` file with sizes and checksums

## Suggested Release Layout

- `v1.0-base-models`
  - `models_distil_gpt2_base.tar.gz.part-*`
- `v1.0-nas-models`
  - `models_distil_gpt2_nas.tar.gz.part-*`
- `v1.0-surrogate`
  - `models_surrogate_models.tar.gz.part-*`
  - `results_surrogate_models.tar.gz.part-*`
- `v1.0-results-models`
  - `results_models.tar.gz.part-*`
- `v1.0-results-nas`
  - `results_nas.tar.gz.part-*`
- `v1.0-results-textgen`
  - `results_text_gen.tar.gz.part-*`

## Operational Flow

1. Run the packaging script.
2. Review `release-assets/manifest.csv`.
3. Authenticate with `gh auth login` and define the remote repository.
4. Run [scripts/release/upload_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/upload_release_assets.sh:1) with the `owner/repo` argument.
5. Create or reuse the releases on GitHub.
6. Upload the corresponding chunks to each release.
7. Keep the release links documented in the `README`.
