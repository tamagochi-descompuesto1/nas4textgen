# nas4textgen

Research project on text generation with `DistilGPT2`, Neural Architecture Search (`NAS`), and surrogate models to accelerate the search process.

Based on the actual contents of the notebooks, scripts, and reports, the repository is organized into these areas:

- `docs/`: reference documentation, Jetson notes, and exported reports.
- `notebooks/`: exploratory Jupyter work, separated into data preparation, modeling, and optimization.
- `scripts/`: reusable scripts outside notebooks.
- `models/`: checkpoints, tokenizers, ONNX exports, and trained models.
- `results/`: experiment outputs, plots, NAS results, and generated text.

## Structure

```text
.
├── docs
│   ├── jetson
│   ├── reference
│   └── reports
├── notebooks
│   ├── data-prep
│   ├── modeling
│   └── optimization
├── scripts
│   └── jetson
├── models
└── results
```

## Practical Notes

- `notebooks/` contains exploratory work. Some notebooks still include legacy Colab paths or older references.
- `scripts/jetson/` concentrates evaluation and telemetry for Jetson execution.
- `scripts/release/package_release_assets.sh` generates the heavy assets intended for `GitHub Releases`.
- `scripts/release/upload_release_assets.sh` publishes those generated assets to `GitHub Releases` using `gh`.
- `docs/reference/nas4textgen.pdf` is the main research document for the project.
- `docs/project-documentation.md` contains the long-form project documentation, based on the manuscript and the real repository contents.
- `docs/releases.md` explains how models and results are distributed outside Git.

## What Should Be Versioned

With the current project layout, heavy artifacts should not be committed directly into Git:

- `models/` is approximately `49G`.
- `results/` is approximately `8.5G`.

This is not only problematic for Git and hosting limits, it also makes cloning, reviewing, and maintaining the repository unnecessarily expensive.

## Recommended Distribution Strategy

- Keep only `docs/`, `notebooks/`, `scripts/`, and configuration files in Git.
- Distribute models and results through `GitHub Releases`.
- Do not use `Git LFS` in this project.
- Do not keep `datasets/` in the local repository or in releases.
- Generate split packages smaller than `2 GiB` with `scripts/release/package_release_assets.sh`.
- Publish those packages with `scripts/release/upload_release_assets.sh <owner/repo>` once `gh` is authenticated.
- Preserve traceability with `release-assets/manifest.csv` and `sha256` checksums.
