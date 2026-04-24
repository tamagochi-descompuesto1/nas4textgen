# Documentacion Integral del Proyecto `nas4textgen`

## 1. Proposito de este documento

Este documento describe de forma extensa el proyecto `nas4textgen` desde dos perspectivas complementarias:

- La perspectiva de investigacion, basada principalmente en el manuscrito [nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1).
- La perspectiva de implementacion, basada en los notebooks, scripts, artefactos y reportes presentes en este repositorio.

La idea es que este archivo funcione como documentacion madre del proyecto: explica que problema se estudia, cual es la propuesta metodologica, como se organiza el repositorio, que contiene cada carpeta, como se relacionan los codigos con la investigacion y cuales son las limitaciones practicas del estado actual del repo.

## 2. Resumen ejecutivo del proyecto

`nas4textgen` es un proyecto de investigacion sobre Neural Architecture Search (NAS) para generacion de texto. La propuesta central consiste en definir un espacio de busqueda inspirado en `DistilGPT2` y explorarlo con algoritmos evolutivos multiobjetivo para encontrar arquitecturas que logren un mejor compromiso entre:

- Calidad semantica de generacion, medida principalmente con `METEOR`.
- Eficiencia del modelo, aproximada durante la busqueda con el numero de parametros y evaluada despues con metricas mas cercanas a hardware real.

El proyecto no se limita a entrenar un modelo de lenguaje. Su contribucion principal es metodologica:

- Diseña un espacio de busqueda continuo y mixto para arquitecturas tipo Transformer inspiradas en DistilGPT2.
- Propone y compara dos estrategias de busqueda multiobjetivo: `SMS-EMOA` y `Lex-MODES`.
- Usa un modelo sustituto o `surrogate model` para predecir `METEOR` y reducir drasticamente el costo computacional de la busqueda.
- Evalua las arquitecturas recuperadas no solo con calidad semantica, sino tambien con indicadores de despliegue en hardware, particularmente sobre Jetson.

El manuscrito reporta que las arquitecturas descubiertas por NAS superan al baseline seleccionado de DistilGPT2 en METEOR y, en varios casos, muestran perfiles de consumo de hardware mas atractivos para entornos restringidos.

## 3. Problema de investigacion

Segun el manuscrito, el proyecto nace de una tension conocida en NLP moderno:

- Los modelos de generacion de texto son cada vez mas capaces.
- Pero ese aumento de capacidad suele venir acompañado de costos computacionales altos.
- Eso complica su uso en dispositivos con recursos limitados, como edge devices o plataformas embebidas.

El documento plantea que el diseño manual de arquitecturas profundas para generacion de texto:

- depende mucho de experiencia humana,
- escala mal conforme crece la complejidad del modelo,
- y no garantiza encontrar configuraciones realmente eficientes para despliegue.

En ese contexto, NAS aparece como una forma de automatizar el diseño arquitectonico. Sin embargo, aplicar NAS a modelos de lenguaje sigue siendo caro y metodologicamente dificil, por varias razones:

- El espacio de busqueda es grande.
- Entrenar cada arquitectura candidata cuesta mucho.
- La mejor arquitectura no depende solo de calidad de texto, sino tambien de consumo de recursos.

La pregunta de investigacion que estructura el proyecto es esencialmente esta:

1. Si es posible integrar un espacio de busqueda basado en DistilGPT2, un esquema de busqueda evolutiva multiobjetivo y un predictor de desempeño en un solo framework NAS para generacion de texto.
2. Si ese framework puede recuperar arquitecturas con compromisos significativos entre calidad semantica y eficiencia orientada a despliegue.

## 4. Aporte principal de la investigacion

De acuerdo con las primeras paginas del PDF, los aportes declarados son:

1. Un framework NAS multiobjetivo para generacion de texto basado en una familia inspirada en DistilGPT2.
2. Un espacio de busqueda continuo y adaptado a generacion de texto, con variables estructurales y funcionales.
3. La incorporacion de un predictor basado en modelo para evitar entrenar exhaustivamente todas las arquitecturas candidatas.
4. La recuperacion de arquitecturas que mejoran el baseline seleccionado en METEOR y que exponen distintos compromisos entre calidad y costo de despliegue.

En otras palabras, el proyecto no solo busca una arquitectura "mejor", sino una familia de arquitecturas con perfiles diferentes:

- unas mas compactas,
- otras mas potentes semanticamente,
- y otras mas balanceadas para hardware.

## 5. Fundamento teorico resumido

El manuscrito dedica una parte importante al marco teorico. Los conceptos clave que sustentan el repo son estos.

### 5.1. Neural Architecture Search

NAS se presenta como un proceso con tres componentes:

- `search space`: conjunto de arquitecturas candidatas.
- `search strategy`: mecanismo para generar y seleccionar candidatas.
- `evaluation strategy`: forma de estimar la calidad de cada candidata.

El proyecto adopta exactamente esa estructura conceptual.

### 5.2. NAS para generacion de texto

El documento sostiene que NAS ha avanzado mucho en vision computacional, pero menos en NLP, y menos aun en tareas de generacion de texto con enfoque hardware-aware.

Por eso el repositorio mezcla varias capas que a primera vista parecen dispersas:

- notebooks de preprocess,
- entrenamiento de DistilGPT2,
- modelado sustituto,
- algoritmos evolutivos,
- y medicion de hardware en Jetson.

Todas esas piezas existen porque el problema no es solo "entrenar un modelo", sino cerrar el ciclo completo de NAS para texto.

### 5.3. NAS multiobjetivo y hardware-aware

El paper adopta la vision de `MoNAS` y `hardware-aware NAS`:

- no optimizar solo calidad,
- sino recuperar soluciones Pareto o lexicograficamente preferidas,
- tomando en cuenta restricciones practicas de despliegue.

Durante la busqueda, la eficiencia se aproxima mediante numero de parametros.

Despues, en la evaluacion final, la eficiencia se mide mas cerca del hardware real mediante:

- consumo de potencia,
- uso de memoria,
- carga de GPU,
- frecuencia de CPU.

Esa separacion entre proxy de eficiencia y eficiencia real es uno de los hallazgos centrales del proyecto.

## 6. Metodologia de investigacion descrita en el PDF

Esta es la columna vertebral conceptual del proyecto.

### 6.1. Arquitectura base

La arquitectura base elegida es `DistilGPT2`, seleccionada por su balance entre capacidad generativa y costo computacional.

El PDF explica que la arquitectura se divide conceptualmente en:

- embedding de texto,
- embedding posicional,
- una pila de unidades Transformer,
- una normalizacion final.

La busqueda NAS solo modifica la parte intermedia: la pila Transformer y sus hiperparametros/parametros arquitectonicos asociados. Los embeddings y la capa final se mantienen fijos.

### 6.2. Representacion de una arquitectura candidata

El manuscrito define una arquitectura candidata como:

`N = [e, l, n, h, r, a, g]`

donde:

- `e`: embedding dimension.
- `l`: maximum embedding sequence length.
- `n`: numero de unidades Transformer.
- `h`: numero de cabezas de atencion.
- `r`: residual dropout.
- `a`: attention dropout.
- `g`: funcion de activacion del FFN.

### 6.3. Dominio de las variables

El paper reporta el siguiente espacio de busqueda:

- `e`: valores proporcionales a `h`, descritos como `{h×1, h×2, ..., h×70}`.
- `l`: `{512, 1024}`.
- `n`: `{2, 4, 6, 12, 24, 48}`.
- `h`: `{4, 8, 12, 16, 32, 64}`.
- `r`: `[0.0, 0.3]`.
- `a`: `[0.0, 0.3]`.
- `g`: `{GeLU, ReLU, Tanh, Swish, Sigmoid}`.

La activacion categorica `g` se mapea al intervalo `[0, 1]` para poder trabajar con una representacion continua:

- `GeLU`: `[0.0, 0.2)`
- `ReLU`: `[0.2, 0.4)`
- `Tanh`: `[0.4, 0.6)`
- `Swish`: `[0.6, 0.8)`
- `Sigmoid`: `[0.8, 1.0]`

El documento estima un tamaño aproximado del espacio de busqueda de `~1.008 × 10^7` al discretizar las variables continuas en 20 bins.

### 6.4. Formulacion multiobjetivo

El problema se formula como biobjetivo:

- Maximizar `METEOR`.
- Minimizar `parameter count`.

La motivacion del paper es clara:

- `METEOR` se adopta como metrica de calidad semantica.
- El numero de parametros se usa como aproximacion interpretable y barata de eficiencia.

El mismo manuscrito advierte que numero de parametros no captura por completo el comportamiento real de despliegue.

### 6.5. Estrategias de busqueda

El proyecto compara dos estrategias principales.

#### 6.5.1. SMS-EMOA

Se usa como optimizador multiobjetivo de referencia.

Segun el PDF:

- evoluciona una poblacion de tamano fijo,
- usa simulated binary crossover y polynomial mutation,
- y la seleccion de sobrevivientes se guía por contribucion al hipervolumen.

El punto de referencia de hipervolumen se fija en `[1×10^9, 0.0]`, negando METEOR para adaptarlo a computacion basada en minimizacion.

#### 6.5.2. Lex-MODES

Esta es la estrategia principal propuesta.

El PDF la describe como una formulacion lexicografica evolutiva que combina:

- una variante de `(µ + 1)` evolution strategy,
- operadores de Differential Evolution,
- y una mecanica de supervivencia inspirada por SMS-EMOA.

Su idea central es sesgar la busqueda hacia eficiencia:

- criterio primario: `parameter count`,
- criterio secundario: `METEOR`.

La intuicion declarada en el manuscrito es que esta presion lexicografica favorece una exploracion mas orientada a hardware y complementa las soluciones de SMS-EMOA.

### 6.6. Operadores en Lex-MODES

El paper especifica:

- esquema `DE/best/1/bin`,
- mutacion basada en el mejor vector actual y dos vectores aleatorios,
- crossover binomial,
- y una etapa de reparacion para mantener validez estructural.

Como la codificacion mezcla variables discretas y continuas, todas se llevan al intervalo `[0, 1]` para operar en un espacio comun y luego se reconstruyen a su dominio original.

### 6.7. Autoadaptacion del factor F

El PDF reporta que `F` puede adaptarse usando la regla del `1/5 success rule`:

- si la razon de exito es baja, el paso se ajusta en una direccion,
- si es alta, se ajusta en la otra,
- con `c = 0.817`.

Esto aparece tambien reflejado en los reportes de resultados, donde se distinguen configuraciones con y sin auto-adaptacion.

### 6.8. Evaluacion basada en modelo sustituto

Esta es una parte critica de la propuesta.

El paper argumenta que entrenar todas las arquitecturas es inviable. Da un ejemplo ilustrativo:

- si cada arquitectura tardara 20 minutos en entrenarse,
- explorar exhaustivamente el espacio requeriria cerca de 140,000 dias.

Por eso, durante la busqueda:

- `METEOR` no se obtiene entrenando cada modelo, sino con un predictor.
- el numero de parametros se estima de forma determinista a partir de la arquitectura reconstruida.

### 6.9. Dataset del predictor

El predictor se entrena con:

- `300` arquitecturas muestreadas del espacio de busqueda,
- completamente entrenadas sobre `WikiText2`,
- usando `Latin hypercube sampling` para cubrir mejor el espacio.

La estructura conceptual del dataset es:

- entrada: arquitectura codificada,
- salida: score `METEOR`.

### 6.10. Candidatos a predictor

El manuscrito considera cuatro regresores:

- `SVR`
- `Random Forest Regressor`
- `XGBoost Regressor`
- `MLP Regressor`

Se normalizan las entradas, se usa `GridSearch` con `3-fold CV`, y luego `10` repeticiones de `5-fold CV` para robustecer la comparacion.

Las metricas de comparacion del predictor son:

- `MAE`
- `MSE`
- `RMSE`
- `MAPE`
- `R²`
- `Pearson`
- `Spearman`

### 6.11. Predictor seleccionado

El PDF concluye que el `MLP Regressor` es el predictor mas adecuado para integrarlo al loop NAS.

La razon que enfatiza el manuscrito no es solo ranking relativo, sino utilidad practica:

- necesita estimaciones suficientemente fieles del objetivo,
- no solo preservar ordenamientos groseros.

Por eso el MLP se privilegia especialmente por evidencia favorable en `RMSE` y `MAPE`.

### 6.12. Protocolo de evaluacion final

El pipeline metodologico del PDF consta de dos grandes etapas:

1. Evaluar un baseline DistilGPT2.
2. Evaluar las arquitecturas seleccionadas por NAS bajo el mismo protocolo.

Esto es importante porque da coherencia experimental:

- el baseline y los modelos NAS se entrenan/evaluan de manera comparable,
- y las diferencias pueden atribuirse a la arquitectura.

### 6.13. Preprocesamiento y entrenamiento

El manuscrito indica:

- uso de `WikiText2`,
- agrupamiento por longitud,
- tokenizacion con tokenizer de DistilGPT2,
- `500` warmup steps,
- `weight decay = 0.01`.

Para la evaluacion final:

- se elimina el ultimo `30%` del texto de cada muestra,
- esa parte se trata como continuacion objetivo,
- el prefijo restante se usa como entrada,
- y la salida generada se compara contra la continuacion original.

## 7. Resultados principales reportados por el PDF

### 7.1. Seleccion del baseline DistilGPT2

El manuscrito compara checkpoints de DistilGPT2 entrenados con:

- `3` epocas
- `5` epocas
- `10` epocas
- `12` epocas
- `15` epocas

Segun la tabla del paper:

- el checkpoint de `3` epocas obtiene el mejor `METEOR` promedio: `0.6961`,
- y no presenta diferencias estadisticamente significativas en los indicadores de hardware frente a checkpoints posteriores.

Por eso se selecciona como baseline final.

### 7.2. Configuraciones de busqueda

El PDF reporta cuatro configuraciones para cada algoritmo, variando:

- numero de experimentos,
- generaciones,
- tamaño de poblacion `µ`,
- auto-adaptacion de `F` en el caso de Lex-MODES.

Las configuraciones pequeñas son exploratorias y las grandes empujan una exploracion mas extensa del espacio.

### 7.3. Comportamiento de SMS-EMOA

El manuscrito concluye que `SMS-EMOA`:

- tendio a permanecer en una region compacta del espacio,
- recupero arquitecturas pequenas,
- y concentro la variacion en ajustes de dropout y, ocasionalmente, de cabezas de atencion.

Es decir, fue bueno encontrando soluciones compactas, pero con diversidad estructural limitada.

### 7.4. Comportamiento de Lex-MODES

Segun el PDF, `Lex-MODES` mostro dos grandes regimenes:

- un atractor compacto alrededor de `[8, 512, 48, 4, 0, 0, 0]`,
- y un atractor de alta capacidad alrededor de `[128, 512, 48, 64, 0, 0.30, 0]`.

Esto sugiere que al aumentar el presupuesto de busqueda cambia el tipo de trade-off dominante que el algoritmo favorece.

### 7.5. Diversidad limitada

Aunque se probaron ocho configuraciones en total, el PDF reporta solo `6` mejores arquitecturas unicas.

Esa baja diversidad se interpreta como una limitacion del framework actual y el propio manuscrito propone varias causas:

- ausencia de mecanismos explicitos de preservacion de diversidad,
- diseño del punto de referencia del hipervolumen,
- expresividad limitada de la codificacion,
- y, para Lex-MODES, la propia presion lexicografica hacia eficiencia.

### 7.6. Modelos retenidos para comparacion final

El paper conserva para comparacion final:

- el baseline DistilGPT2,
- `Model 1`: solucion compacta recurrente de Lex-MODES,
- `Model 2`: solucion recurrente de alta capacidad en Lex-MODES,
- `Model 3`: solucion ligera representativa de SMS-EMOA,
- `Model 4`: candidata intermedia de complejidad media.

### 7.7. Comparacion final de calidad y hardware

El PDF reporta:

- baseline DistilGPT2 (3 epocas): `METEOR = 0.6961`
- Model 1: `0.7200`
- Model 2: `0.7000`
- Model 3: `0.7000`
- Model 4: `0.7000`

Interpretacion del manuscrito:

- Todos los modelos NAS mejoran al baseline en METEOR.
- `Model 1` es el mejor semanticamente, pero el menos atractivo en varios indicadores de hardware.
- `Model 2` es el mejor en eficiencia hardware real.
- `Model 4` ofrece el compromiso mas equilibrado.

### 7.8. Hallazgo conceptual clave

El hallazgo mas importante del paper es que:

- minimizar parametros ayuda,
- pero no basta para predecir eficiencia real de despliegue.

Dos arquitecturas competitivas en el espacio `METEOR + parameter count` pueden comportarse de manera muy distinta en memoria, CPU, GPU y potencia.

Ese punto explica por que el proyecto incluye herramientas de medicion sobre Jetson: no son accesorias, son parte de la validacion del planteamiento.

## 8. Conclusiones de investigacion segun el PDF

El manuscrito concluye que:

1. NAS puede adaptarse con exito a generacion de texto.
2. El framework propuesto recupera trade-offs utiles entre calidad semantica y eficiencia.
3. Las arquitecturas NAS superan al baseline en METEOR.
4. Algunas arquitecturas tambien mejoran sustancialmente el perfil de hardware.
5. El framework actual aun tiene dos debilidades grandes:
   - usar solo numero de parametros como proxy de eficiencia,
   - y explorar una porcion relativamente estrecha del espacio.

Las lineas de trabajo futuro propuestas por el paper incluyen:

- codificaciones arquitectonicas mas ricas,
- mecanismos de diversidad mas fuertes,
- objetivos hardware-aware explicitos,
- pruning,
- quantization,
- mixed precision,
- distillation,
- validacion en mas datasets y tareas.

## 9. Relacion entre la investigacion y el repositorio

El repositorio refleja casi todo el pipeline experimental del manuscrito, aunque en un formato de trabajo de investigacion mas que de paquete de software productizado.

En lugar de una libreria modular con `src/`, `tests/` y `configs/`, aqui hay una mezcla de:

- notebooks de exploracion,
- scripts de evaluacion,
- checkpoints entrenados,
- datasets crudos y procesados,
- resultados y graficas,
- documentos auxiliares.

Eso es coherente con un proyecto academico en evolucion.

## 10. Organizacion actual del repositorio

Despues de la reorganizacion fisica, el repositorio queda conceptualmente asi:

```text
nas4textgen/
├── docs/
│   ├── jetson/
│   ├── reference/
│   ├── reports/
│   └── project-documentation.md
├── notebooks/
│   ├── data-prep/
│   ├── modeling/
│   └── optimization/
├── scripts/
│   └── jetson/
├── datasets/
├── models/
├── results/
├── README.md
└── .gitignore
```

### 10.1. `docs/`

Esta carpeta contiene documentacion humana y reportes.

#### `docs/reference/`

- [nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1): manuscrito principal del proyecto. Es la referencia mas importante para entender la motivacion, metodologia, experimentos y conclusiones.

#### `docs/reports/`

- [model-characterization.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/model-characterization.docx:1): caracterizacion de modelos NAS y configuraciones.
- [nas-results.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/nas-results.docx:1): resumen/reportes de corridas NAS, configuraciones y salidas visuales o analiticas.

#### `docs/jetson/`

- [cons.txt](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons.txt:1)
- [cons.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons.docx:1)
- [cons2.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons2.docx:1)

Estos archivos parecen ser bitacoras o notas operativas del entorno Jetson, incluyendo instalacion de paquetes y comandos de sistema. No son parte del pipeline cientifico principal, pero si documentan el entorno experimental real.

### 10.2. `notebooks/`

Aqui vive la mayor parte del trabajo exploratorio y experimental.

#### `notebooks/data-prep/`

- [dataset-processing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/data-prep/dataset-processing.ipynb:1)
- [transformers-environment.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/data-prep/transformers-environment.ipynb:1)

#### `notebooks/modeling/`

- [model-testing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/model-testing.ipynb:1)
- [surrogate-models.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/surrogate-models.ipynb:1)

#### `notebooks/optimization/`

- [smsmodes.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/optimization/smsmodes.ipynb:1)

### 10.3. `scripts/`

Contiene scripts mas reutilizables o mas cerca de ejecucion directa fuera de notebook.

#### `scripts/jetson/`

- [jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1)
- [test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1)

### 10.4. `datasets/`

Contiene datasets crudos y procesados. Esta carpeta es masiva y no deberia versionarse en Git tradicional.

Estructura observada:

- `datasets/raw/cola`
- `datasets/raw/spanish_corpora`
- `datasets/wikitext-2/raw`
- `datasets/wikitext-2/processed`

### 10.5. `models/`

Contiene:

- checkpoints base de DistilGPT2,
- exportaciones ONNX,
- tokenizer,
- modelos NAS entrenados,
- modelos del surrogate.

Estructura observada:

- `models/distil-gpt2/base`
- `models/distil-gpt2/nas/trained-models`
- `models/surrogate-models/models`

### 10.6. `results/`

Almacena:

- plots,
- resultados de NAS,
- resultados de surrogate,
- resultados de generacion de texto,
- resumentes/modelos serializados.

Estructura observada:

- `results/models`
- `results/nas/evo-strat/smsemoa`
- `results/nas/evo-strat/smsmodes`
- `results/surrogate-models`
- `results/text-gen/distil-gpt2/base`
- `results/text-gen/distil-gpt2/nas`

## 11. Descripcion detallada de los notebooks

### 11.1. `dataset-processing.ipynb`

Este notebook parece cumplir una funcion de preparacion de datos temprana o auxiliar.

Por sus encabezados, cubre:

- dataset `CoLA`,
- lectura de archivos `.tsv`,
- limpieza de caracteres,
- tokenizacion,
- construccion de representacion numerica,
- procesamiento de corpus en español.

Tecnologias e ideas visibles:

- `csv`
- `re`
- `nltk`
- `Tokenizer` de `tensorflow.keras`
- `os`

Interpretacion:

- Este notebook parece anterior o paralelo a la parte principal de DistilGPT2.
- Sugiere que el proyecto paso por una fase de exploracion mas general sobre preprocesamiento de texto.
- La presencia de `CoLA` y corpus en español indica que el repositorio conserva materiales que ayudaron a construir intuicion o pipelines previos, aunque el paper final se centra en `WikiText2` y generacion de texto sobre arquitectura inspirada en DistilGPT2.

### 11.2. `transformers-environment.ipynb`

Este notebook parece ser una pieza temprana de experimentacion para construir un modelo de generacion de texto.

Encabezados observados:

- `Text generation model`
- `Data preparation`
- `Building the model`
- `Layers of the model`
- `Training the model`
- `Testing and saving the model`

Tecnologias visibles:

- `torch`
- `numpy`
- `matplotlib`
- `Tokenizer` de `tensorflow.keras`
- tokenizacion con `nltk`

Interpretacion:

- Parece documentar una fase inicial en la que se explora la construccion de un modelo generativo y su entorno.
- Es util para entender la evolucion del proyecto, aunque probablemente no sea el pipeline final reportado en el paper.

### 11.3. `model-testing.ipynb`

Este notebook se alinea fuertemente con la evaluacion del baseline y posiblemente con la comparacion entre checkpoints/modelos.

Imports visibles:

- `GPT2LMHeadModel`, `GPT2Tokenizer`
- `datasets.load_dataset`
- `TrainingArguments`
- `GenerationConfig`
- `StratifiedKFold`
- `pickle`
- `pandas`

Interpretacion funcional:

- carga modelos GPT2/DistilGPT2,
- trabaja con datasets y estratificacion,
- probablemente calcula metricas de comparacion y guarda resultados,
- parece conectado con la seleccion del baseline descrita en el PDF.

### 11.4. `surrogate-models.ipynb`

Este notebook esta directamente ligado a la seccion de `Model-based Evaluation` del manuscrito.

Cabeceras visibles:

- `S_model`
- `FLOPs`

Imports relevantes:

- `SVR`
- `XGBRegressor`
- `MLPRegressor`
- `RandomForestRegressor`
- `StandardScaler`
- `pearsonr`, `spearmanr`
- `qmc` para muestreo
- `thop.profile`
- `baycomp`

Interpretacion:

- implementa el entrenamiento y evaluacion comparativa de los candidatos a predictor,
- probablemente carga el dataset de arquitecturas y scores desde `models/surrogate-models/data.txt`,
- calcula metricas de error y correlacion,
- y respalda la decision de seleccionar `MLP` como predictor principal.

Es uno de los notebooks mas cercanos a la contribucion metodologica central del paper.

### 11.5. `smsmodes.ipynb`

Este es probablemente el notebook mas importante del proyecto desde el punto de vista de NAS.

Cabeceras observadas:

- `S-Metric Selection Multi Objective Differential Evolution Strategy`
- `NAS`
- `Loading dependencies`
- `New misc functions`
- `Objective function`
- `Surrogate model for predicting meteor score`
- `Parameter count`
- `Search process`
- `Config 1`

Imports relevantes:

- `deap.tools.sortNondominated`
- `scipy.stats.qmc`
- `joblib`
- `torch`
- `transformers.GPT2Config`, `GPT2LMHeadModel`, `GPT2Tokenizer`
- `torch.profiler`
- `imageio`, `PIL`

Interpretacion:

- implementa el loop de busqueda NAS,
- incluye las utilidades para representar arquitecturas,
- integra el surrogate para predecir METEOR,
- estima numero de parametros,
- ejecuta el proceso evolutivo,
- y probablemente genera salidas para visualizacion de Pareto fronts, GIFs y progreso evolutivo.

Este notebook es la pieza que mejor corresponde al corazon del framework descrito en el PDF.

## 12. Descripcion detallada de los scripts de Jetson

### 12.1. `jtop_stats.py`

El script [jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1) encapsula recoleccion de metricas de hardware usando la libreria `jtop`.

Funciones practicas del script:

- leer potencia, memoria, CPU y GPU del sistema Jetson,
- calcular deltas temporales,
- suavizar medidas para evitar picos espurios,
- resumir historicos,
- y volcar resultados a archivo.

Tipos de metricas que maneja:

- voltaje, corriente y potencia promedio,
- RAM usada, libre, cache y compartida,
- frecuencia por nucleo de CPU,
- carga y frecuencia de GPU.

Este script conecta directamente con la parte del manuscrito donde se reportan mediciones de:

- power consumption,
- memory usage,
- GPU utilization,
- CPU frequency.

Es decir, no es una utilidad secundaria; es parte del mecanismo que permite pasar de un proxy barato de eficiencia a una evaluacion mas fiel de comportamiento de despliegue.

### 12.2. `test_distilgpt2.py`

El script [test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1) parece orientado a:

- cargar multiples checkpoints de DistilGPT2,
- generar texto sobre un dataset,
- comparar las continuaciones generadas contra referencias,
- calcular metricas NLP,
- y cruzar eso con datos de hardware del entorno Jetson.

Elementos funcionales visibles:

- corte del ultimo 30 por ciento del texto para formar el objetivo,
- generacion autoregresiva,
- calculo de `BLEU`, `GLEU`, `METEOR`, `ROUGE-1`, `ROUGE-2`, `ROUGE-L`,
- lectura y agregacion de metricas,
- visualizaciones con `matplotlib` y `seaborn`.

Eso coincide con el protocolo descrito en el PDF para:

- usar el prefijo como entrada,
- tratar el tramo final como continuacion objetivo,
- y medir calidad semantica de la salida.

Observacion importante:

- el script parece conservar rutas historicas como `models/distilgpt2/...`, mientras en el repo reorganizado existe `models/distil-gpt2/...`.
- tambien importa `jtop_stats` de una forma que probablemente requiera ajuste para ejecutarse hoy sin modificar `PYTHONPATH`.

Eso no invalida su valor documental, pero indica que el repositorio aun mezcla material experimental con distinto nivel de madurez.

## 13. Datasets del proyecto

### 13.1. `WikiText2`

Es el dataset principal de la investigacion reportada en el PDF.

Se usa para:

- entrenar el baseline DistilGPT2,
- entrenar las arquitecturas muestreadas para construir el dataset del predictor,
- y evaluar modelos con el protocolo de continuacion de texto.

En el repo aparecen:

- datos crudos en `datasets/wikitext-2/raw`
- datos procesados en `datasets/wikitext-2/processed`

La existencia de varios archivos `.pkl` procesados sugiere diferentes configuraciones de longitud maxima, por ejemplo `256`, `512`, `1024`, `2048`.

### 13.2. `CoLA`

`datasets/raw/cola` contiene archivos del corpus CoLA.

Aunque el paper final no se centra en CoLA, este material parece haber servido para etapas exploratorias o para notebooks de preprocesamiento y modelado previos.

### 13.3. Corpus en español

`datasets/raw/spanish_corpora` contiene varios archivos de texto grandes:

- `UN.txt`
- `TED.txt`
- `ParaCrawl.txt`
- `OpenSubtitles2018.txt`
- `NewsCommentary11.txt`
- `multiUN.txt`
- `JRC.txt`
- `GlobalVoices.txt`
- `Europarl.txt`
- `EUBookShop.txt`
- `EMEA.txt`
- `ECB.txt`
- `DOGC.txt`
- `DGT.txt`
- `all_wikis.txt`

Interpretacion:

- estos datos no parecen estar en el centro del experimento final del paper,
- pero muestran que el proyecto o su fase preparatoria tuvo interes en corpora multifuente y posiblemente en escenarios de texto en español.

## 14. Modelos almacenados en el repositorio

### 14.1. Modelos base de DistilGPT2

En `models/distil-gpt2/base` hay:

- tokenizer,
- checkpoints por numero de epocas,
- exportaciones ONNX.

Esto refleja la parte del proyecto dedicada a:

- elegir baseline,
- entrenar variantes base,
- y posiblemente probar opciones de despliegue.

### 14.2. Modelos NAS entrenados

En `models/distil-gpt2/nas/trained-models` existe una gran coleccion de carpetas, cada una asociada a una arquitectura codificada en su nombre.

Eso coincide con la idea del proyecto:

- una arquitectura se representa como una tupla de valores,
- se reconstruye como modelo,
- se entrena,
- y se guarda.

Estas carpetas parecen ser evidencia material del proceso de exploracion y evaluacion de candidatos NAS.

### 14.3. Modelos del surrogate

En `models/surrogate-models/models` se observan artefactos como:

- `scaler.pkl`
- `mlp_reg.pkl`

Eso corresponde de forma directa a la etapa de evaluacion model-based descrita en el paper.

## 15. Resultados almacenados

### 15.1. Resultados de surrogate

`results/surrogate-models/plots` contiene graficas comparativas entre regresores en metricas como:

- `MAE`
- `MAPE`
- `MSE`
- `RMSE`
- `R²`
- `Pearson`
- `Spearman`

Esto es practicamente la contraparte visual de la seccion del PDF donde se selecciona el `MLP Regressor`.

### 15.2. Resultados de modelos base y NAS

`results/models` contiene:

- plots como `loss_vs_epoch`, `epochs_vs_bleu`, `epochs_vs_meteor`, etc.
- artefactos serializados como `best_models.pkl`, `all_best_fitness.pkl`, `F_arr.pkl`.

Esto parece documentar:

- evolucion de entrenamiento,
- comparacion entre checkpoints,
- y seleccion/caracterizacion de mejores modelos.

### 15.3. Resultados de NAS

`results/nas` y en particular `results/nas/evo-strat` parecen contener las salidas de los algoritmos evolutivos:

- experimentos de `smsemoa`,
- experimentos de `smsmodes`,
- posiblemente frentes de Pareto, progreso de hipervolumen, convergencia y evolucion de `F`.

Eso coincide punto por punto con las figuras y descripciones del manuscrito.

### 15.4. Resultados de generacion de texto

`results/text-gen/distil-gpt2/base` y `results/text-gen/distil-gpt2/nas` contienen textos de salida generados por modelos base y NAS.

Estos resultados ayudan a:

- auditar cualitativamente el comportamiento del modelo,
- rastrear experimentos,
- y respaldar el calculo de metricas.

## 16. Flujo de trabajo end-to-end inferido del proyecto

Integrando PDF, notebooks, scripts y carpetas, el flujo general del proyecto parece ser este:

1. Preparar datasets y tokenizacion.
2. Entrenar y evaluar checkpoints base de DistilGPT2.
3. Seleccionar un baseline.
4. Muestrear arquitecturas del espacio de busqueda.
5. Entrenarlas completamente para construir el dataset del surrogate.
6. Ajustar y comparar varios regresores.
7. Seleccionar el mejor predictor.
8. Ejecutar NAS con `SMS-EMOA` y `Lex-MODES`, usando:
   - predictor para estimar METEOR,
   - conteo de parametros para eficiencia.
9. Retener arquitecturas representativas de los principales regimenes encontrados.
10. Entrenar esas arquitecturas seleccionadas.
11. Evaluarlas con el mismo protocolo del baseline.
12. Medir comportamiento de hardware en Jetson.
13. Comparar semanticamente y en eficiencia real.
14. Redactar resultados y conclusiones.

## 17. Estado del repositorio como artefacto de investigacion

Este repo funciona bien como archivo de investigacion, pero no todavia como paquete reproducible listo para terceros.

Fortalezas:

- contiene el manuscrito principal,
- conserva notebooks y scripts clave,
- almacena resultados, modelos y trazas suficientes para respaldar la investigacion,
- y documenta tanto la parte algoritmica como la parte hardware.

Debilidades:

- hay dependencia fuerte de notebooks,
- existen rutas historicas y referencias heredadas,
- no se observa un sistema unico de configuracion reproducible,
- faltan manifiestos claros de dependencias,
- y el volumen de artefactos pesados dificulta la colaboracion por Git.

## 18. Observaciones tecnicas sobre organizacion y mantenibilidad

### 18.1. Lo que esta bien separado ahora

La reorganizacion actual ya distingue razonablemente entre:

- documentacion,
- notebooks,
- scripts,
- datasets,
- modelos,
- resultados.

Eso mejora mucho la navegacion del proyecto.

### 18.2. Lo que sigue mezclado conceptualmente

Todavia hay mezcla entre:

- artefactos finales del paper,
- exploraciones tempranas,
- pruebas de entorno,
- y codigo ejecutable.

Eso es normal en un proyecto academico, pero conviene explicitarlo. Este documento justamente ayuda a eso.

### 18.3. Lo que convendria modularizar a futuro

Si en algun momento quieres convertir esto en un repositorio mas reproducible o publicable, tendria sentido separar:

- `src/` con codigo reusable de NAS, surrogate y evaluacion,
- `configs/` con experimentos y parametros,
- `notebooks/` solo como exploracion o visualizacion,
- `artifacts/` o almacenamiento externo para pesos y resultados.

## 19. Tamaño del repositorio y recomendacion de versionado

El arbol actual es enorme:

- `datasets/` ronda `20G`
- `models/` ronda `49G`
- `results/` ronda `8.5G`

Implicaciones:

- Git tradicional no es buena opcion para esto.
- Aunque algunos hosts permitan grandes repositorios, la experiencia de clonacion, diff y mantenimiento se degrada mucho.
- El riesgo de llegar a limites practicos de almacenamiento y transferencia es alto.

Por eso el repo ya incluye `.gitignore` para excluir:

- `datasets/`
- `models/`
- `results/`

Recomendacion concreta:

1. Versionar solo `docs/`, `notebooks/`, `scripts/`, `README.md`, configuraciones y pequenos metadatos.
2. Mantener datasets, checkpoints y resultados grandes fuera de Git.
3. Si necesitas rastrear artefactos grandes, usar `Git LFS`, DVC o almacenamiento externo con manifiestos ligeros.

## 20. Que archivos son especialmente importantes

Si alguien nuevo quisiera entender el proyecto rapido, el orden recomendado seria:

1. [docs/reference/nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1)
2. [docs/project-documentation.md](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/project-documentation.md:1)
3. [notebooks/optimization/smsmodes.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/optimization/smsmodes.ipynb:1)
4. [notebooks/modeling/surrogate-models.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/surrogate-models.ipynb:1)
5. [notebooks/modeling/model-testing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/model-testing.ipynb:1)
6. [scripts/jetson/jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1)
7. [scripts/jetson/test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1)
8. [docs/reports/nas-results.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/nas-results.docx:1)
9. [docs/reports/model-characterization.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/model-characterization.docx:1)

## 21. Lectura interpretativa del proyecto

Mas alla del detalle tecnico, este repo cuenta la historia de una investigacion con varias capas:

- una capa de NLP y generacion de texto,
- una capa de NAS evolutivo,
- una capa de surrogate modeling,
- y una capa de evaluacion real en hardware restringido.

Esa combinacion es lo que vuelve interesante al proyecto. No es solo "buscar hiperparametros" ni solo "correr DistilGPT2", sino conectar:

- diseño automatico de arquitectura,
- costo computacional,
- y viabilidad de despliegue.

El PDF deja claro que esa es la tesis central del trabajo, y el repositorio conserva evidencia de casi todas las etapas necesarias para sostenerla.

## 22. Limitaciones documentales de este repositorio

Aunque el manuscrito es fuerte, el repositorio todavia tiene vacios comunes de proyectos de investigacion:

- no existe una lista consolidada de dependencias exactas,
- no hay una guia unica de reproduccion paso a paso,
- no se observan tests automatizados,
- algunos notebooks y scripts parecen conservar residuos de Colab o rutas antiguas,
- y hay muchos artefactos que son valiosos como registro, pero ruidosos como software.

Eso no le quita valor academico. Solo significa que la documentacion es especialmente importante para volver navegable el trabajo.

## 23. Recomendaciones para evolucionar esta documentacion

Este archivo puede crecer en varias direcciones utiles:

1. Agregar una cronologia del proyecto y versiones del manuscrito.
2. Crear una `reproducibility-guide.md` con comandos exactos y dependencias.
3. Crear una tabla maestra de modelos NAS retenidos, con arquitectura, parametros, METEOR y metricas hardware.
4. Crear un glosario de variables del espacio de busqueda.
5. Crear una guia para reconstruir `results/` sin subir los binarios.

## 24. Conclusion general

`nas4textgen` es un proyecto de investigacion sobre generacion de texto y Neural Architecture Search con una orientacion clara hacia eficiencia y despliegue en hardware restringido. El manuscrito principal demuestra que la propuesta:

- define un espacio de busqueda coherente basado en DistilGPT2,
- usa evolucion multiobjetivo para explorar compromisos entre calidad y complejidad,
- reduce el costo de evaluacion con un surrogate model,
- y consigue arquitecturas que mejoran al baseline en METEOR, con perfiles de hardware distintos y utiles.

El repositorio conserva los componentes materiales de esa investigacion:

- notebooks de preparacion, modelado y optimizacion,
- scripts de medicion sobre Jetson,
- datasets, checkpoints y resultados,
- y documentos de apoyo y reporte.

Como repositorio de investigacion, su valor es alto. Como repositorio de software reproducible, todavia necesita consolidacion adicional. Precisamente por eso esta documentacion busca servir como puente entre ambas cosas: explicar no solo que archivos existen, sino que historia metodologica cuentan y como se conectan con la investigacion descrita en el PDF.
