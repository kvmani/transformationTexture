
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

### `beta2AlphaTexture.m`

Performs batch β→α transformation:
- Uses `beta2alphaVariants.m` for orientation computation
- Supports optional pre-existing α inclusion
- Generates ODF files and pole figure PNGs

### `alpha2BetaTexture.m`

Performs α→β transformation in reverse:
- Uses `alpha2betaVariants.m` with 6 variants
- Follows similar output and folder structure

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
- MTEX Toolbox **v6.0.0**
- Operating System: **Windows 10 Pro (Build 19041)**
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

## How to Run

### Install MTEX 5.4.0
1. Download MTEX version 5.4.0 from the [official release page](https://github.com/mtex-toolbox/mtex/releases/tag/5.4.0).
2. Extract the archive to a folder, e.g. `C:\mtex-5.4.0`.
3. Start MATLAB R2020a and execute:

   ```matlab
   addpath('C:\mtex-5.4.0');
   startup_mtex;
   mtex_version
   ```
   Ensure that `mtex_version` reports **5.4.0**.

### Configure MATLAB with this Repository
1. Clone or download this repository to a local folder.
2. In MATLAB add the folder to the path:

   ```matlab
   addpath(genpath('path_to_transformationTexture'));
   ```
3. Run `checkEnvironment` to verify MATLAB and MTEX versions.

### Running the Interactive Demo
Open and run `parentToProductTexture.mlx` in the MATLAB editor. Edit the
file paths in the first code cell to point to your own `odf.txt` files and
press **Run All**. Output pole figures and ODF files will appear under the
`results` folder.

### Interpreting Results
The live script prints a `report` structure summarising the run. Pole figure
PNGs are saved alongside the ODF file indicated in the report.

#### Troubleshooting
- **Undefined function errors**: ensure MTEX is on the MATLAB path and that
  `startup_mtex` has been executed.
- **Path conflicts**: run `restoredefaultpath` before adding MTEX and this
  repository to avoid shadowed functions.
- **Version mismatch**: `checkEnvironment` will error if MATLAB is older than
  R2020a or if MTEX is not exactly 5.4.0.
- **Missing toolbox**: the scripts require the *Statistics and Machine
  Learning Toolbox*. Install it using the MATLAB Add-On manager if needed.

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
