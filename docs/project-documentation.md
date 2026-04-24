# Comprehensive Project Documentation for `nas4textgen`

## 1. Purpose of This Document

This document provides a detailed description of the `nas4textgen` project from two complementary perspectives:

- The research perspective, based primarily on [nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1).
- The implementation perspective, based on the notebooks, scripts, artifacts, and reports contained in this repository.

Its purpose is to act as the main documentation layer for the repository. It explains:

- the research problem,
- the proposed methodology,
- the repository layout,
- the role of each major file and directory,
- the relationship between the code and the manuscript,
- and the practical constraints of maintaining this project as a research repository.

## 2. Executive Summary

`nas4textgen` is a research project on Neural Architecture Search (`NAS`) for text generation. Its core proposal is to define a DistilGPT2-inspired search space and explore it with multi-objective evolutionary search in order to recover architectures that balance:

- semantic text-generation quality, mainly measured with `METEOR`,
- and model efficiency, approximated during search with parameter count and later evaluated with hardware-oriented metrics.

The project is not just about training a text-generation model. Its main contribution is methodological:

- It designs a continuous mixed search space for Transformer-based architectures inspired by DistilGPT2.
- It proposes and compares two multi-objective search strategies: `SMS-EMOA` and `Lex-MODES`.
- It uses a surrogate model to predict `METEOR`, reducing the computational cost of the search.
- It evaluates the discovered architectures not only in terms of semantic quality but also in terms of deployment-oriented hardware behavior, especially on Jetson hardware.

According to the manuscript, the recovered architectures improve the selected DistilGPT2 baseline in `METEOR` and expose meaningful trade-offs between semantic quality and deployment efficiency.

## 3. Research Problem

The manuscript is built around a common tension in modern NLP:

- text-generation models are becoming more capable,
- but that capability often comes with a high computational cost,
- which makes deployment in constrained environments much harder.

The document argues that manual architecture design for text generation:

- depends heavily on expert knowledge,
- scales poorly as model complexity grows,
- and does not guarantee efficient architectures for practical deployment.

In that context, NAS becomes a natural way to automate architectural design. However, applying NAS to text-generation models is still expensive and methodologically difficult because:

- the search space is large,
- training every candidate architecture is costly,
- and the best architecture must account for both quality and deployment constraints.

The underlying research question is essentially this:

1. Can a DistilGPT2-based search space, a multi-objective evolutionary search process, and a model-based performance predictor be integrated into one NAS framework for text generation?
2. Can that framework recover architectures with meaningful trade-offs between semantic quality and deployment-oriented efficiency?

## 4. Main Research Contributions

From the manuscript highlights and abstract, the main contributions are:

1. A multi-objective NAS framework for text generation based on a DistilGPT2-inspired family of architectures.
2. A continuous search space tailored to text generation, with structural and functional design variables.
3. A model-based performance predictor that avoids exhaustive training of every candidate architecture.
4. A set of recovered architectures that improve the selected baseline in `METEOR` while revealing different deployment-oriented trade-offs.

The project is therefore not looking for one universally best architecture. It is looking for a set of architectures with different profiles:

- more compact models,
- more semantically competitive models,
- and more balanced models for deployment.

## 5. Theoretical Background

The manuscript grounds the project in several key ideas.

### 5.1. Neural Architecture Search

NAS is described through three canonical components:

- `search space`: the set of candidate architectures.
- `search strategy`: the mechanism used to generate and select candidates.
- `evaluation strategy`: the method used to estimate candidate quality.

The project follows exactly that structure.

### 5.2. NAS for Text Generation

The manuscript argues that NAS has progressed substantially in computer vision, but much less in NLP and especially in hardware-aware text generation.

That is why this repository contains a combination of:

- data preparation notebooks,
- baseline model training and evaluation,
- surrogate modeling,
- evolutionary search,
- and Jetson hardware instrumentation.

Those components are not accidental. They reflect the full NAS pipeline required to support the research claim.

### 5.3. Multi-objective and Hardware-aware NAS

The project adopts the perspective of multi-objective NAS and hardware-aware NAS:

- not optimizing quality alone,
- but recovering trade-off architectures,
- while considering deployment constraints.

During search, efficiency is approximated with parameter count.

During final evaluation, efficiency is measured more concretely through device-level indicators:

- power consumption,
- memory usage,
- GPU utilization,
- CPU frequency.

That distinction between a cheap efficiency proxy and real deployment behavior becomes one of the manuscript’s main findings.

## 6. Research Methodology from the Manuscript

This section summarizes the conceptual backbone of the project.

### 6.1. Baseline Architecture

The selected baseline is `DistilGPT2`, chosen because it offers a reasonable balance between generation capability and computational efficiency.

The manuscript conceptually splits the architecture into:

- text embedding,
- positional embedding,
- a stack of Transformer units,
- a final normalization layer.

The NAS process only modifies the middle Transformer stack and its associated design variables. Embeddings and the final normalization stage remain fixed.

### 6.2. Candidate Representation

The manuscript defines a candidate architecture as:

`N = [e, l, n, h, r, a, g]`

where:

- `e`: embedding dimension
- `l`: maximum embedding sequence length
- `n`: number of Transformer units
- `h`: number of attention heads
- `r`: residual dropout
- `a`: attention dropout
- `g`: FFN activation function

### 6.3. Search-Space Variables

The paper reports the following search space:

- `e`: values proportional to `h`, written as `{h×1, h×2, ..., h×70}`
- `l`: `{512, 1024}`
- `n`: `{2, 4, 6, 12, 24, 48}`
- `h`: `{4, 8, 12, 16, 32, 64}`
- `r`: `[0.0, 0.3]`
- `a`: `[0.0, 0.3]`
- `g`: `{GeLU, ReLU, Tanh, Swish, Sigmoid}`

The categorical activation `g` is mapped to `[0, 1]`:

- `GeLU`: `[0.0, 0.2)`
- `ReLU`: `[0.2, 0.4)`
- `Tanh`: `[0.4, 0.6)`
- `Swish`: `[0.6, 0.8)`
- `Sigmoid`: `[0.8, 1.0]`

The manuscript estimates an approximate search-space size of `~1.008 × 10^7` when discretizing continuous dimensions into 20 bins.

### 6.4. Multi-objective Formulation

The problem is formulated as a bi-objective optimization task:

- maximize `METEOR`
- minimize `parameter count`

The paper motivates that choice as follows:

- `METEOR` is used as the semantic quality target,
- parameter count is used as a practical and interpretable proxy for efficiency.

The paper also explicitly states that parameter count is not a complete description of real deployment cost.

### 6.5. Search Strategies

Two main search strategies are evaluated.

#### 6.5.1. SMS-EMOA

`SMS-EMOA` is used as the reference multi-objective evolutionary optimizer.

According to the manuscript:

- it evolves a fixed-size population,
- uses simulated binary crossover and polynomial mutation,
- and selects survivors based on hypervolume contribution.

The hypervolume reference point is `[1×10^9, 0.0]`, with `METEOR` negated to adapt to minimization-based hypervolume computation.

#### 6.5.2. Lex-MODES

`Lex-MODES` is the main lexicographic strategy proposed in the project.

The paper describes it as a formulation that combines:

- a variant of `(µ + 1)` evolution strategy,
- Differential Evolution operators,
- and an SMS-EMOA-inspired survival mechanism.

Its key idea is to bias the search toward efficiency:

- primary ranking criterion: `parameter count`
- tie-breaking criterion: `METEOR`

The stated motivation is that this lexicographic pressure should recover more hardware-oriented architectures and complement SMS-EMOA’s solution set.

### 6.6. Lex-MODES Operators

The manuscript specifies:

- `DE/best/1/bin`,
- mutation based on the current best vector and two random vectors,
- binomial crossover,
- and a repair stage to restore valid architectures.

Because the representation mixes discrete and continuous variables, all alleles are mapped to `[0, 1]` so that DE operators can be applied uniformly before decoding them back into valid architectural values.

### 6.7. Self-adaptation of `F`

The paper reports a self-adaptation mechanism for `F` using the `1/5 success rule`:

- if the success ratio is below the threshold, the step size changes one way,
- if it is above the threshold, it changes the other way,
- using `c = 0.817`.

This also appears in the experiment summaries, where some Lex-MODES configurations enable self-adaptation and others do not.

### 6.8. Model-based Evaluation

This is one of the core practical ideas of the project.

The manuscript argues that fully training all candidates is infeasible. It gives a concrete example:

- if each architecture required 20 minutes of training,
- exhaustive exploration would take nearly 140,000 days.

So during search:

- `METEOR` is estimated by a predictor rather than full training,
- parameter count is computed deterministically after decoding the candidate architecture.

### 6.9. Surrogate Training Data

The predictor is trained with:

- `300` architectures sampled from the search space,
- fully trained on `WikiText2`,
- using Latin hypercube sampling to improve coverage of the design space.

Conceptually, the dataset looks like:

- input: encoded architecture
- output: observed `METEOR`

### 6.10. Predictor Candidates

The manuscript evaluates four regressors:

- `SVR`
- `Random Forest Regressor`
- `XGBoost Regressor`
- `MLP Regressor`

Inputs are normalized, the models are tuned with `GridSearch` and `3-fold CV`, and then evaluated through `10` repetitions of `5-fold CV`.

The reported evaluation metrics are:

- `MAE`
- `MSE`
- `RMSE`
- `MAPE`
- `R²`
- `Pearson`
- `Spearman`

### 6.11. Selected Predictor

The manuscript concludes that `MLP Regressor` is the most suitable predictor for integration into the NAS loop.

The key argument is not just relative ordering of candidates, but practical usefulness:

- the NAS process needs estimates that are accurate enough to guide optimization,
- not merely a rough ranking.

For that reason, `MLP` is especially favored in the manuscript because of its evidence on `RMSE` and `MAPE`.

### 6.12. Final Evaluation Protocol

The final pipeline described in the paper has two major stages:

1. Train and evaluate a DistilGPT2 baseline.
2. Train and evaluate the architectures selected by NAS under the same protocol.

That makes the comparison methodologically consistent:

- baseline and NAS models are trained and evaluated in comparable ways,
- and the observed differences can be attributed to the architectures themselves.

### 6.13. Preprocessing and Training Setup

The manuscript specifies:

- `WikiText2` as the main dataset,
- grouping texts by length,
- tokenization with the DistilGPT2 tokenizer,
- `500` warm-up steps,
- `weight decay = 0.01`

For final evaluation:

- the last `30%` of each sample is removed,
- that segment becomes the target continuation,
- the remaining prefix becomes the input,
- and the generated continuation is compared against the held-out continuation.

## 7. Main Results Reported in the Manuscript

### 7.1. DistilGPT2 Baseline Selection

The manuscript compares checkpoints trained for:

- `3` epochs
- `5` epochs
- `10` epochs
- `12` epochs
- `15` epochs

According to the reported table:

- the `3`-epoch checkpoint reaches the highest average `METEOR`: `0.6961`,
- and later checkpoints do not show statistically significant hardware advantages.

That is why the `3`-epoch checkpoint is selected as the final baseline.

### 7.2. Search Configurations

The paper reports four configurations for each algorithm, varying:

- number of experiments,
- generation budget,
- population size `µ`,
- and self-adaptation of `F` in the case of Lex-MODES.

The smaller configurations act as exploratory regimes, while the larger ones encourage broader search.

### 7.3. Behavior of SMS-EMOA

According to the paper, `SMS-EMOA`:

- remained largely confined to a compact region of the space,
- repeatedly recovered small architectures,
- and concentrated most variation on dropout and, sometimes, the number of attention heads.

That means it was good at finding compact solutions, but with limited structural diversity.

### 7.4. Behavior of Lex-MODES

The manuscript reports two main regimes for `Lex-MODES`:

- a compact attractor around `[8, 512, 48, 4, 0, 0, 0]`,
- and a high-capacity attractor around `[128, 512, 48, 64, 0, 0.30, 0]`.

This suggests that increasing the search budget changes the dominant trade-off regime that the optimizer prefers.

### 7.5. Limited Diversity

Even though eight configurations were evaluated overall, the paper reports only `6` unique best architectures.

The manuscript interprets that low diversity as a limitation of the current setup and mentions several possible causes:

- absence of explicit diversity-preservation mechanisms,
- hypervolume reference-point design,
- limited expressive power of the encoding,
- and, for Lex-MODES, the lexicographic pressure toward efficiency.

### 7.6. Final Models Retained for Comparison

The paper keeps the following models for final comparison:

- the DistilGPT2 baseline,
- `Model 1`: a recurrent compact Lex-MODES solution,
- `Model 2`: a recurrent high-capacity Lex-MODES solution,
- `Model 3`: a representative lightweight SMS-EMOA solution,
- `Model 4`: an intermediate-complexity Lex-MODES candidate.

### 7.7. Final Comparison: Quality and Hardware

The manuscript reports:

- DistilGPT2 baseline (3 epochs): `METEOR = 0.6961`
- Model 1: `0.7200`
- Model 2: `0.7000`
- Model 3: `0.7000`
- Model 4: `0.7000`

The paper’s interpretation is:

- all NAS models outperform the baseline in `METEOR`,
- `Model 1` is semantically strongest but hardware-wise less attractive,
- `Model 2` is the strongest hardware-oriented result,
- `Model 4` is the most balanced compromise.

### 7.8. Main Conceptual Finding

One of the most important findings is that:

- minimizing parameter count helps,
- but it is not enough to characterize real deployment efficiency.

Two architectures can look similarly competitive in the `METEOR + parameter count` search space and still behave very differently in memory usage, CPU demand, GPU utilization, and power consumption.

That is exactly why the Jetson measurement tooling is important in this repository.

## 8. Conclusions from the Manuscript

The manuscript concludes that:

1. NAS can be adapted successfully to text generation.
2. The proposed framework recovers useful trade-offs between semantic quality and efficiency.
3. The selected NAS architectures outperform the baseline in `METEOR`.
4. Some candidates also improve deployment-oriented hardware profiles substantially.
5. The current framework still has two major limitations:
   - using parameter count as the only search-time efficiency proxy,
   - and exploring only a relatively narrow portion of the space.

The manuscript proposes several future directions:

- richer architectural encodings,
- stronger diversity mechanisms,
- explicit hardware-aware objectives,
- pruning,
- quantization,
- mixed precision,
- distillation,
- validation on more datasets and tasks.

## 9. How the Research Maps to This Repository

The repository reflects almost the entire experimental pipeline from the manuscript, although in the form of a research workspace rather than a polished software package.

Instead of a modular library with `src/`, `tests/`, and `configs/`, this project contains a mixture of:

- exploratory notebooks,
- evaluation scripts,
- trained checkpoints,
- raw and processed datasets,
- results and plots,
- supporting documents.

That is consistent with an academic research repository in active development.

## 10. Current Repository Organization

After the structural reorganization, the repository looks conceptually like this:

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
│   ├── jetson/
│   └── release/
├── models/
├── results/
├── README.md
└── .gitignore
```

### 10.1. `docs/`

This directory contains human-readable documentation and reports.

#### `docs/reference/`

- [nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1): the main research manuscript. It is the most important single reference for understanding the motivation, methodology, experiments, and conclusions.

#### `docs/reports/`

- [model-characterization.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/model-characterization.docx:1): characterization notes for NAS models and configurations.
- [nas-results.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/nas-results.docx:1): summaries of NAS runs, configurations, and reported outputs.

#### `docs/jetson/`

- [cons.txt](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons.txt:1)
- [cons.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons.docx:1)
- [cons2.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/jetson/cons2.docx:1)

These files appear to be Jetson environment notes, including package installation history and system-level setup commands. They are not part of the scientific contribution itself, but they document the real experimental environment.

### 10.2. `notebooks/`

This is where most exploratory and experimental work lives.

#### `notebooks/data-prep/`

- [dataset-processing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/data-prep/dataset-processing.ipynb:1)
- [transformers-environment.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/data-prep/transformers-environment.ipynb:1)

#### `notebooks/modeling/`

- [model-testing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/model-testing.ipynb:1)
- [surrogate-models.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/surrogate-models.ipynb:1)

#### `notebooks/optimization/`

- [smsmodes.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/optimization/smsmodes.ipynb:1)

### 10.3. `scripts/`

This directory holds reusable scripts or workflows closer to direct execution than notebook exploration.

#### `scripts/jetson/`

- [jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1)
- [test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1)

#### `scripts/release/`

- [package_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/package_release_assets.sh:1)
- [upload_release_assets.sh](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/release/upload_release_assets.sh:1)

These release scripts were added to distribute large models and results through `GitHub Releases` rather than Git commits or `Git LFS`.

### 10.4. `models/`

This directory contains:

- base DistilGPT2 checkpoints,
- tokenizer assets,
- ONNX exports,
- NAS-trained models,
- surrogate-model artifacts.

Observed structure:

- `models/distil-gpt2/base`
- `models/distil-gpt2/nas/trained-models`
- `models/surrogate-models/models`

### 10.5. `results/`

This directory stores:

- plots,
- NAS outputs,
- surrogate-model results,
- text-generation outputs,
- serialized summaries of best models and search artifacts.

Observed structure:

- `results/models`
- `results/nas/evo-strat/smsemoa`
- `results/nas/evo-strat/smsmodes`
- `results/surrogate-models`
- `results/text-gen/distil-gpt2/base`
- `results/text-gen/distil-gpt2/nas`

## 11. Detailed Notebook Overview

### 11.1. `dataset-processing.ipynb`

This notebook appears to handle early or auxiliary data preparation work.

From its headings, it covers:

- the `CoLA` dataset,
- reading `.tsv` files,
- special-character cleanup,
- tokenization,
- building a numeric representation,
- processing Spanish corpora.

Visible technologies:

- `csv`
- `re`
- `nltk`
- `tensorflow.keras.preprocessing.text.Tokenizer`
- `os`

Interpretation:

- this notebook likely predates or complements the main DistilGPT2 pipeline,
- it shows a broader text-processing exploration phase,
- and it indicates that the repository preserves materials from earlier or parallel experimentation beyond the final paper scope.

### 11.2. `transformers-environment.ipynb`

This notebook appears to belong to an early experimentation phase for building a text-generation model environment.

Observed headings:

- `Text generation model`
- `Data preparation`
- `Building the model`
- `Layers of the model`
- `Training the model`
- `Testing and saving the model`

Visible technologies:

- `torch`
- `numpy`
- `matplotlib`
- `tensorflow.keras.preprocessing.text.Tokenizer`
- `nltk`

Interpretation:

- it documents an earlier generative-model setup workflow,
- and it is useful for understanding how the project evolved,
- even if it does not represent the final pipeline exactly as reported in the paper.

### 11.3. `model-testing.ipynb`

This notebook aligns closely with baseline evaluation and likely checkpoint comparison.

Visible imports include:

- `GPT2LMHeadModel`, `GPT2Tokenizer`
- `datasets.load_dataset`
- `TrainingArguments`
- `GenerationConfig`
- `StratifiedKFold`
- `pickle`
- `pandas`

Functional interpretation:

- loads GPT2 or DistilGPT2 models,
- works with datasets and stratification,
- likely computes comparison metrics and stores results,
- and seems closely connected to the baseline-selection stage described in the manuscript.

### 11.4. `surrogate-models.ipynb`

This notebook is directly connected to the `Model-based Evaluation` section of the manuscript.

Visible headings:

- `S_model`
- `FLOPs`

Relevant imports:

- `SVR`
- `XGBRegressor`
- `MLPRegressor`
- `RandomForestRegressor`
- `StandardScaler`
- `pearsonr`, `spearmanr`
- `qmc`
- `thop.profile`
- `baycomp`

Interpretation:

- it implements training and evaluation of the surrogate candidates,
- it likely loads the architecture-score dataset from `models/surrogate-models/data.txt`,
- it computes error and correlation metrics,
- and it supports the manuscript’s decision to choose `MLP` as the main predictor.

This is one of the notebooks most closely tied to the central methodological contribution of the project.

### 11.5. `smsmodes.ipynb`

This is likely the most important notebook in the repository from the NAS perspective.

Observed headings:

- `S-Metric Selection Multi Objective Differential Evolution Strategy`
- `NAS`
- `Loading dependencies`
- `New misc functions`
- `Objective function`
- `Surrogate model for predicting meteor score`
- `Parameter count`
- `Search process`
- `Config 1`

Relevant imports:

- `deap.tools.sortNondominated`
- `scipy.stats.qmc`
- `joblib`
- `torch`
- `transformers.GPT2Config`, `GPT2LMHeadModel`, `GPT2Tokenizer`
- `torch.profiler`
- `imageio`, `PIL`

Interpretation:

- it implements the NAS loop,
- includes candidate representation logic,
- integrates the surrogate predictor,
- estimates parameter count,
- runs the evolutionary search,
- and likely generates outputs for Pareto fronts, GIFs, convergence plots, and related analysis.

This notebook maps most directly to the methodological core described in the manuscript.

## 12. Detailed Jetson Script Overview

### 12.1. `jtop_stats.py`

The script [jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1) wraps hardware measurement through the `jtop` library.

Its practical responsibilities include:

- reading power, memory, CPU, and GPU statistics from Jetson,
- computing deltas over time,
- smoothing noisy measurements,
- summarizing histories,
- and dumping those values to files.

Handled metrics include:

- voltage, current, and average power,
- used, free, cached, and shared RAM,
- per-core CPU frequency,
- GPU load and frequency.

This script directly supports the hardware-oriented evaluation reported in the manuscript:

- power consumption,
- memory usage,
- GPU utilization,
- CPU frequency.

It is therefore part of the experimental validation, not just an auxiliary utility.

### 12.2. `test_distilgpt2.py`

The script [test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1) appears to be designed to:

- load multiple DistilGPT2 checkpoints,
- generate text from a dataset,
- compare generated continuations against references,
- compute NLP metrics,
- and combine those with hardware measurements collected on Jetson.

Visible functional elements include:

- cutting the last 30 percent of each text to build the continuation target,
- autoregressive generation,
- computation of `BLEU`, `GLEU`, `METEOR`, `ROUGE-1`, `ROUGE-2`, and `ROUGE-L`,
- aggregation and plotting of runtime metrics.

That matches the final evaluation protocol described in the manuscript:

- use the prefix as input,
- hold out the last segment as the target continuation,
- and score the output semantically.

Important observation:

- the script still seems to contain legacy paths such as `models/distilgpt2/...`, while the reorganized repository uses `models/distil-gpt2/...`.
- it also imports `jtop_stats` in a way that may require path adjustments to run cleanly today.

That does not reduce its documentary value, but it does show that the repository still contains experimental code at different maturity levels.

## 13. Datasets Used in the Project

The repository previously contained large datasets, but they were removed from the local tree to save disk space and because the current publication strategy focuses on models and results rather than raw data distribution.

From the remaining notebooks and manuscript, the important datasets were:

### 13.1. `WikiText2`

This is the main dataset in the published research workflow.

It is used to:

- train the DistilGPT2 baseline,
- train the sampled architectures used to build the surrogate dataset,
- evaluate text-generation quality under the continuation protocol.

### 13.2. `CoLA`

The repository also contains evidence of experiments involving the `CoLA` dataset, especially in earlier data-processing notebooks.

### 13.3. Spanish Corpora

The notebooks also reference large Spanish corpora from multiple sources, indicating that the project preserved a wider text-processing exploration phase beyond the exact final paper pipeline.

## 14. Stored Models

### 14.1. Base DistilGPT2 Models

Inside `models/distil-gpt2/base`, the repository stores:

- tokenizer files,
- checkpoints organized by training epochs,
- ONNX exports.

This corresponds to the part of the project devoted to:

- training baseline variants,
- selecting a reference checkpoint,
- and exploring deployable model exports.

### 14.2. NAS-trained Models

Inside `models/distil-gpt2/nas/trained-models`, there is a large collection of directories named after encoded architectures.

That matches the core NAS logic:

- encode an architecture,
- decode and instantiate it,
- train it,
- store the resulting model.

These directories are material evidence of the explored NAS candidates.

### 14.3. Surrogate Artifacts

Inside `models/surrogate-models/models`, artifacts such as:

- `scaler.pkl`
- `mlp_reg.pkl`

directly correspond to the model-based evaluation stage described in the manuscript.

## 15. Stored Results

### 15.1. Surrogate Results

`results/surrogate-models/plots` contains comparative plots for regressors across metrics such as:

- `MAE`
- `MAPE`
- `MSE`
- `RMSE`
- `R²`
- `Pearson`
- `Spearman`

This is the visual counterpart of the predictor-selection section in the manuscript.

### 15.2. Baseline and NAS Model Results

`results/models` contains:

- plots such as `loss_vs_epoch`, `epochs_vs_bleu`, `epochs_vs_meteor`, and related summaries,
- serialized artifacts such as `best_models.pkl`, `all_best_fitness.pkl`, and `F_arr.pkl`.

These results appear to document:

- training behavior,
- checkpoint comparisons,
- and selection/characterization of best architectures.

### 15.3. NAS Search Results

`results/nas` and especially `results/nas/evo-strat` appear to store outputs from the evolutionary search itself:

- experiments for `smsemoa`,
- experiments for `smsmodes`,
- and likely Pareto-front, hypervolume, convergence, and `F` evolution outputs.

This maps directly to the figures and discussion in the manuscript.

### 15.4. Text-generation Results

`results/text-gen/distil-gpt2/base` and `results/text-gen/distil-gpt2/nas` store text-generation outputs from baseline and NAS models.

These are useful for:

- qualitative inspection,
- experiment traceability,
- and support for metric computation.

## 16. Inferred End-to-End Workflow

Putting the manuscript, notebooks, scripts, and artifact layout together, the overall workflow of the project appears to be:

1. Prepare datasets and tokenization.
2. Train and evaluate DistilGPT2 baseline checkpoints.
3. Select a baseline checkpoint.
4. Sample architectures from the search space.
5. Train those architectures fully to build the surrogate dataset.
6. Fit and compare surrogate regressors.
7. Select the best predictor.
8. Run NAS with `SMS-EMOA` and `Lex-MODES`, using:
   - a predictor for `METEOR`,
   - parameter count for efficiency.
9. Retain architectures representing the main recovered trade-off regimes.
10. Train those selected architectures.
11. Evaluate them under the same protocol as the baseline.
12. Measure hardware behavior on Jetson.
13. Compare semantic quality and deployment-oriented behavior.
14. Report conclusions in manuscript and supporting documents.

## 17. Repository State as a Research Artifact

This repository works well as a research archive, but not yet as a polished reproducible software package.

Strengths:

- it contains the main manuscript,
- it preserves key notebooks and scripts,
- it stores models, plots, and outputs that support the research,
- and it documents both the algorithmic and hardware-oriented parts of the work.

Weaknesses:

- there is strong notebook dependence,
- some scripts and paths are still historical,
- there is no single reproducibility entry point,
- dependencies are not yet consolidated into one canonical environment specification,
- and the volume of heavy artifacts makes Git-based collaboration difficult.

## 18. Organizational and Maintainability Observations

### 18.1. What Is Already Better Organized

The current repository structure clearly separates:

- documentation,
- notebooks,
- scripts,
- models,
- results.

That already improves navigation substantially.

### 18.2. What Is Still Conceptually Mixed

There is still some blending between:

- final paper artifacts,
- early exploratory work,
- environment notes,
- and executable code.

That is common in academic projects, but it is worth documenting explicitly.

### 18.3. What Would Be Worth Modularizing Later

If the project is ever turned into a more reproducible or public-facing software package, it would make sense to split it into:

- `src/` for reusable NAS, surrogate, and evaluation code,
- `configs/` for experiment definitions,
- `notebooks/` for exploration and visualization only,
- `artifacts/` or external storage for large binary outputs.

## 19. Repository Size and Distribution Strategy

The remaining heavy artifact tree is large:

- `models/` is roughly `49G`
- `results/` is roughly `8.5G`

Implications:

- Git is not the right place for direct binary versioning at this scale.
- Even when hosting is possible, cloning, diffing, and maintenance become inefficient.
- Transfer and storage overhead quickly become unnecessary.

For that reason, the repository now uses `.gitignore` and release scripts to:

- keep the source-oriented repository light,
- distribute models and results through `GitHub Releases`,
- and avoid `Git LFS` entirely for this project.

## 20. Most Important Files for New Readers

If a new collaborator wants to understand the project quickly, this is a good reading order:

1. [docs/reference/nas4textgen.pdf](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reference/nas4textgen.pdf:1)
2. [docs/project-documentation.md](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/project-documentation.md:1)
3. [notebooks/optimization/smsmodes.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/optimization/smsmodes.ipynb:1)
4. [notebooks/modeling/surrogate-models.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/surrogate-models.ipynb:1)
5. [notebooks/modeling/model-testing.ipynb](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/notebooks/modeling/model-testing.ipynb:1)
6. [scripts/jetson/jtop_stats.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/jtop_stats.py:1)
7. [scripts/jetson/test_distilgpt2.py](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/scripts/jetson/test_distilgpt2.py:1)
8. [docs/reports/nas-results.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/nas-results.docx:1)
9. [docs/reports/model-characterization.docx](/mnt/c/Users/usuario/Documents/GitHub/nas4textgen/docs/reports/model-characterization.docx:1)

## 21. High-level Reading of the Project

Beyond the implementation details, this repository tells the story of a research effort that combines several layers:

- NLP and text generation,
- evolutionary NAS,
- surrogate modeling,
- and real hardware evaluation under constrained deployment conditions.

That combination is what makes the project interesting. It is not just about tuning hyperparameters or running DistilGPT2, but about linking:

- automated architecture design,
- computational cost,
- and practical deployability.

The manuscript makes that thesis explicit, and the repository preserves evidence of nearly every stage required to support it.

## 22. Documentation Limitations of the Current Repository

Even though the manuscript is strong, the repository still has common research-project gaps:

- no single consolidated dependency list,
- no one-command reproducibility guide,
- no automated test suite,
- some notebooks and scripts retain legacy Colab paths or environment assumptions,
- many artifacts are valuable as records but noisy as software.

That does not reduce the project’s academic value. It simply means that documentation is especially important for making the repository navigable.

## 23. Recommended Documentation Extensions

This document could be extended in several useful ways:

1. Add a project timeline or revision history.
2. Add a reproducibility guide with exact commands and dependencies.
3. Add a master table of retained NAS models, with architecture, parameter count, `METEOR`, and hardware metrics.
4. Add a glossary for search-space variables.
5. Add an artifact reconstruction guide for regenerating results without storing all binaries in Git.

## 24. Final Conclusion

`nas4textgen` is a research project on text generation and Neural Architecture Search with a clear emphasis on efficiency and deployment under constrained hardware conditions. The main manuscript shows that the proposed framework:

- defines a coherent DistilGPT2-based search space,
- uses multi-objective evolutionary search to explore trade-offs between quality and complexity,
- reduces evaluation cost with a surrogate model,
- and recovers architectures that outperform the chosen baseline in `METEOR`, while exposing different hardware profiles.

The repository preserves the material components of that work:

- notebooks for preparation, modeling, and optimization,
- Jetson measurement scripts,
- trained models and results,
- and supporting reports and documentation.

As a research repository, it is already valuable. As a fully reproducible software package, it still needs consolidation. This document is intended to bridge those two states by explaining not only which files exist, but also what methodological story they tell and how they relate to the research described in the manuscript.
