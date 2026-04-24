# nas4textgen

Proyecto de experimentacion para generacion de texto con `DistilGPT2`, exploracion de arquitecturas por `NAS` y uso de modelos sustitutos para acelerar la busqueda.

Por el contenido de los notebooks, scripts y reportes, el repositorio queda organizado en estas areas:

- `docs/`: documentacion de referencia, notas de Jetson y reportes exportados.
- `notebooks/`: trabajo exploratorio en Jupyter, separado por preparacion de datos, modelado y optimizacion.
- `scripts/`: scripts reutilizables fuera de notebook.
- `models/`: checkpoints, tokenizers, ONNX y modelos entrenados.
- `results/`: resultados, graficas, salidas NAS y generaciones de texto.

## Estructura

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

## Notas practicas

- `notebooks/` contiene trabajo exploratorio. Algunos notebooks todavia tienen rutas historicas de Colab o referencias antiguas.
- `scripts/jetson/` concentra la evaluacion y telemetria para ejecucion en Jetson.
- `scripts/release/package_release_assets.sh` genera los assets pesados para `GitHub Releases`.
- `scripts/release/upload_release_assets.sh` publica los assets generados a `GitHub Releases` usando `gh`.
- `docs/reference/nas4textgen.pdf` queda como documento principal del proyecto.
- `docs/project-documentation.md` concentra la documentacion extensa del proyecto, basada en el manuscrito y en el contenido real del repo.
- `docs/releases.md` documenta como se distribuyen modelos y resultados fuera de Git.

## Que conviene versionar

Con el estado actual del arbol, no conviene subir a Git los artefactos pesados directamente en commits:

- `models/` ocupa alrededor de `49G`.
- `results/` ocupa alrededor de `8.5G`.

Eso no solo choca con limites practicos de Git y de hosting, tambien hace muy costoso clonar, revisar y mantener el repo.

## Distribucion recomendada

- Mantener en Git solo `docs/`, `notebooks/`, `scripts/` y archivos de configuracion.
- Distribuir modelos y resultados mediante `GitHub Releases`.
- No usar `Git LFS` en este proyecto.
- No conservar `datasets/` en el repo local ni en releases.
- Generar paquetes partidos de menos de `2 GiB` con `scripts/release/package_release_assets.sh`.
- Publicar esos paquetes con `scripts/release/upload_release_assets.sh <owner/repo>` una vez que `gh` este autenticado.
- Conservar trazabilidad con `release-assets/manifest.csv` y checksums `sha256`.
