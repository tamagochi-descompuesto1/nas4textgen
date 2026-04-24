# Releases y artefactos

Este proyecto distribuye sus artefactos pesados mediante `GitHub Releases`, no mediante `Git LFS`.

## Que se publica en Releases

- Checkpoints base de `DistilGPT2`
- Modelos NAS entrenados
- Modelos del surrogate
- Resultados de `results/models`
- Resultados de `results/nas`
- Resultados de `results/surrogate-models`
- Resultados de `results/text-gen`

## Que no se publica

- `datasets/`

Los datasets fueron eliminados del arbol local del proyecto para ahorrar espacio y porque no son necesarios para distribuir los resultados principales del trabajo.

## Como se empaquetan los assets

El script [scripts/release/package_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/package_release_assets.sh:1) empaqueta los artefactos pesados en archivos `tar.gz` partidos en fragmentos de `1900 MiB`, que quedan por debajo del limite de `2 GiB` por asset de GitHub Releases.

Cada paquete genera:

- archivos `.part-*`
- un archivo `.sha256` por cada fragmento
- un `manifest.csv` con tamanos y checksums

## Distribucion sugerida en Releases

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

## Flujo operativo

1. Ejecutar el script de empaquetado.
2. Revisar `release-assets/manifest.csv`.
3. Autenticarse con `gh auth login` y definir el repositorio remoto.
4. Ejecutar [scripts/release/upload_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/upload_release_assets.sh:1) con el argumento `owner/repo`.
5. Crear o reutilizar los releases en GitHub.
6. Subir a cada release los fragmentos correspondientes.
5. Conservar en el `README` los enlaces a esos releases.
