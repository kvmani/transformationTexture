# coding_guidelines.md

## 🧩 Coding Guidelines for `transformationTexture` Repository

This document outlines the **mandatory rules** for contributing to the `transformationTexture` project, which models crystallographic texture evolution during β↔α phase transformations in Zr/Ti alloys using MTEX and MATLAB.

All contributors **must** follow these guidelines to ensure correctness, maintainability, and scientific integrity of the project.

---

## 🔍 Project Philosophy

This project simulates crystallographic **texture evolution** under the **Burgers orientation relationship**, particularly during:
- The **Burgers OR** is given by **[111]β ‖ [0001]α, (110)β ‖ (11̅20)α**
- **β → α transformation** (e.g., cooling from high-temperature bcc β-phase)
- **α → β transformation** (e.g., reheating or reverse transformation)

It incorporates:
- **Variant selection** using a user-defined `sel` parameter
- **Weighted mixing** of pre-existing phase textures (if present)
- A **modular and metadata-driven workflow** using `.json` inputs

---

## 💻 Technical Requirements

- **MATLAB Version**: `9.8.0.1323502 (R2020a)`
- **MTEX Version**: `5.4.0`


⚠️ *All code must be compatible with the above environment. No features from newer MATLAB or MTEX versions may be used unless explicitly backported.*

---

## 📚 Documentation Standards

All MATLAB functions and scripts must follow these rules:

### 🧾 Function Headers
- Use standard MATLAB docstring format describing:
  - Purpose
  - Input arguments
  - Output arguments
  - Author and date

### ✍️ Inline Comments
- Use clear and concise comments for:
  - Mathematical operations
  - Transformation logic
  - Variant construction and selection

### 📘 Project Documentation
If a function is added, updated, or removed:
- Update **`README.md`** with revised explanation and examples.
- Update any helper modules (like `local_functions.m`).
- Mention changes in the log or changelog if maintained.

---

## 🧪 Unit Testing

For every core function:
- Add a test script named `test_<functionName>.m`.
- Cover:
  - Input validity
  - Boundary conditions
  - Transformation correctness

Tests should:
- Run non-interactively (no GUI or user input)
- Use assertions or logical checks
- Document expected output in comments

---

## 🧱 Structure and Modularity

- **Main transformation workflows**:
  - `beta2AlphaTexture.m`
  - `alpha2BetaTexture.m`

- **Transformation logic** should delegate to:
  - `beta2alphaVariants.m` and `alpha2betaVariants.m`
  - `alphaVariantsFromBeta.m` and `betaVariantsFromAlpha.m`
  - `buildBurgersVariantOperators.m` or `buildBetaVariantsFromAlpha.m`

- Use `local_functions.m` for reusable helpers like:
  - `getCleanDataSetName`
  - `plotAndSaveODF`
  - `addFigureAnnotation`

---

## 📦 Metadata and Inputs

- Inputs are described in JSON with the following fields:

| Field                          | Meaning                                                           |
|-------------------------------|--------------------------------------------------------------------|
| `folder`                      | Path to the texture data folder (relative to rootDir)              |
| `data_set_name`               | Short unique identifier (used for annotation)                      |
| `pre-transformed-alpha-present` | Boolean flag for pre-existing α texture (in β → α)                |
| `pre-transformed-alpha-texture-data` | Path to α texture to be included in mixing                     |
| `pre-transformed-alpha-fraction`     | Weight fraction (e.g., 0.2 for 20%)                             |
| `files`                       | List of XRDML pole figure files (used elsewhere in pipeline)       |

- All JSON inputs must be validated before use. Fallbacks (e.g., synthetic names) must be defined if `data_set_name` is absent.

---

## 🔎 Debug and Logging

When `debug = true`, all processing:
- Should use every 40th row from `odf.txt`
- Must print warnings or messages to the command window
- Should break after first dataset to speed up test iteration

Use `warning()` or `fprintf()` clearly to signal debug behavior.

---

## ✅ Style and Quality

- Follow consistent variable naming:
  - `gAlpha`, `wAlpha`, `gBeta`, `wBeta`, `sel`, `alphaFrac`
- Use `orientation`, `quaternion`, and `calcODF` objects efficiently
- Avoid unnecessary `if` nesting or deep indentation
- Ensure all figures are saved as `.png` with resolution ≥ 300 dpi

---

## 🧑‍🔬 Attribution

Each script or function must include:

```matlab
% Author: Dr K V Mani Krishna
% Date  : YYYY-MM-DD
