
# Crystallographic Texture Transformation Toolkit

## Overview

This project provides a MATLAB-based computational framework to simulate **crystallographic texture evolution** during solid-state phase transformations between the β (BCC) and α (HCP) phases of titanium alloys. It enables:
- Forward transformation: **β → α** using the Burgers orientation relationship (BOR)
- Reverse transformation: **α → β** using the inverse OR operators

The transformations account for:
- Multiple orientation variants per parent grain
- The effect of *variant selection* via a parameter `sel ∈ [0, 1]`
- Contribution from **pre-existing transformed phase fractions**

Author: **Dr K V Mani Krishna**

---

## Algorithms & Workflow

### 🔁 Beta to Alpha (β → α)

1. Load experimental β-texture from `.odf.txt`
2. Compute 12 possible α variants using fixed BOR operators
3. Select top `n = round(sel * 12)` variants
4. Construct weighted α ODF
5. Optionally mix with pre-existing α ODF using `"pre_transformed_alpha_fraction"`

### 🔁 Alpha to Beta (α → β)

1. Load experimental α-texture
2. Apply 6 inverse BOR operators to generate β variants
3. Select `n = round(sel * 6)` variants
4. Construct weighted β ODF
5. Optionally include pre-existing β texture

---

## Scripts

### `parentToProductTexture.m`

Generic function that converts a parent phase texture into its product phase
using the Burgers orientation relationship. It handles both α→β and β→α cases,
optional pre-transformed fractions and writes a JSON report. The legacy batch
scripts call this function internally.

### `beta2AlphaTexture.m`

Wrapper for batch β→α transformation:
- Calls `parentToProductTexture` for each dataset
- Supports optional pre-existing α inclusion
- Generates ODF files and pole figure PNGs

### `alpha2BetaTexture.m`

Wrapper for α→β transformation in reverse:
- Also delegates to `parentToProductTexture`
- Follows similar output and folder structure

### `simulateUniModalBeta2AlphaTexture.m` & `simulateUniModalAlpha2BetaTexture.m`

Self-contained examples that build an ideal single-orientation texture and
invoke `parentToProductTexture` for several `sel` values. They write all
generated ODFs and pole figures to `results/simulatedTextures/` and are a
handy way to confirm the toolkit is working without external data files.

Running either script is an easy check that the transformation functions and
your MTEX setup are behaving correctly. They also validate that your MATLAB
version is at least R2020a and that MTEX 5.4.0 is on the path.


---

## Supporting Functions

| Function                      | Purpose                                                  |
|------------------------------|----------------------------------------------------------|
| `buildBurgersVariantOperators`     | 12 α-variant operators for β→α                        |
| `buildBetaVariantsFromAlpha`      | 6 β-variant operators for α→β                        |
| `beta2alphaVariants`         | Converts β ODF → α ODF using BOR                        |
| `alpha2betaVariants`         | Converts α ODF → β ODF using inverse BOR               |
| `alphaVariantsFromBeta`      | Applies operators to a β grain to get α variants       |
| `betaVariantsFromAlpha`      | Applies reverse operators to α → β variants            |
| `plotAndSaveODF`             | Plot pole figures and save them                        |
| `getCleanDataSetName`        | Extracts readable name from metadata                   |
| `addFigureAnnotation`        | Annotates plots with `sel`, fraction, dataset name     |

---

## Input Format: JSON Metadata

### Example
```json
{
  "folder": "Path\to\beta",
  "data_set_name": "Sample1_beta",
  "pre_transformed_alpha_present": true,
  "pre_transformed_alpha_texture_data": "Path\to\alpha",
  "pre_transformed_alpha_fraction": 0.2,
  "files": [
    { "file": "PF1.xrdml", "hkl": [1,1,0], "twoTheta": 38.43 }
  ]
}
```

### Required Fields:
- `folder`: relative path where `odf.txt` exists
- `data_set_name`: short name for annotations and files
- `pre_transformed_alpha_present` (bool): whether to include pre-existing α
- `pre_transformed_alpha_texture_data`: path to α folder
- `pre_transformed_alpha_fraction`: fraction of α added (0.0 to 1.0)

For α→β transformations, replace `alpha` with `beta` in the metadata keys accordingly.

---

## Dependencies

**Environment Requirements:**
- MATLAB **R2020a**
- MTEX Toolbox **v5.4.0**
- Java 1.8.0_202 (HotSpot 64-bit)

### MTEX installation:
Refer to [https://mtex-toolbox.github.io](https://mtex-toolbox.github.io)

---

## Usage Instructions

1. Ensure `odf.txt` exists in each dataset folder (exported from XRDML using MTEX)
2. Configure `selList` in the script to define selection levels
3. Modify paths to your local `rootDir`
4. (Optional) Override input JSON by setting `manualJsonText` in the script

Run either:

```matlab
beta2AlphaTexture
```

or

```matlab
alpha2BetaTexture
```

to simulate transformations and generate results.

---

## Output

Each simulation generates:
- `*.odf` file of the transformed phase
- `*.png` pole figure annotated with:
  - `sel`
  - Phase fraction
  - Dataset name

---

## License

This work is intended for academic and research purposes.

© 2025 **Dr K V Mani Krishna**
