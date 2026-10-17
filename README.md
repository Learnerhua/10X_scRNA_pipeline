# 10X-scRNA

<p align="center">
  <a href="https://www.10xgenomics.com/support/software/cell-ranger"><img src="https://img.shields.io/badge/Cell%20Ranger-10.0.0-00A1DE.svg" alt="Cell Ranger"></a>
  <a href="https://www.r-project.org"><img src="https://img.shields.io/badge/R-4.x-276DC3.svg?logo=r&logoColor=white" alt="R"></a>
  <a href="https://www.kernel.org"><img src="https://img.shields.io/badge/Platform-Linux%20x86__64-FCC624.svg?logo=linux&logoColor=black" alt="Platform: Linux"></a>
  <a href="https://www.10xgenomics.com/datasets"><img src="https://img.shields.io/badge/Data-10x%20PBMC%201k%20v3-green" alt="Data: 10x PBMC 1k v3"></a>
</p>

**Cell Ranger 10 counting + Seurat downstream + bilingual HTML/PDF report** · [中文说明](README.zh-CN.md)

End-to-end single-cell RNA-seq pipeline for 10x Genomics data: `cellranger count` → optional `cellranger annotate` →
in-house Seurat downstream analysis → Chinese/English HTML + PDF report.

📖 **`10X_scRNA_SOP.md`** — step-by-step Chinese SOP for this pipeline: Cell Ranger installation, reference genome
preparation (prebuilt & custom `mkref`), FASTQ preparation (BCL conversion), `cellranger count`, output file
interpretation, `cellranger annotate`, and how to adapt the downstream scripts (`dataprepare.sh`, `Getinfo.R`,
`Pipeline_plot.R`, report files) to a new project.

The repository is also a worked example — every directory is the real output of one demo run
(`run_count_1kpbmcs`, human PBMC 1k v3, 11 clusters), so file layout and file names at each stage are shown as produced.

> **⚠️ Files larger than 1 MiB are zero-byte placeholders.** 153 of them (STAR indices, genome FASTA/GTF,
> FASTQ, BAM, `.RDS`, matrix `.h5`, report PDFs) were emptied to keep the repo at 210 MB instead of 65 GB.
> Scripts were never replaced. Restore with:
>
> ```bash
> find . -type f -size 0 -printf '%P\n' > placeholders.txt   # 153 entries
> while read -r f; do cp -a "/path/to/full_dataset/$f" "./$f"; done < placeholders.txt
> ```

## Pipeline

| Stage | Tool | Main output |
|---|---|---|
| Counting | `cellranger count --create-bam true --localcores 48 --localmem 1000`, STAR vs `refdata-gex-GRCh38-2024-A` | `run_count_1kpbmcs/outs/` |
| Annotation (optional) | `cellranger annotate --cell-annotation-model=auto` (10x Cloud token) | `run_annotate_1kpbmcs/outs/cell_types.csv` |
| Downstream | Seurat / R, driven by a `.sh.sign` marker scheduler | `DowAna/Res/<sample>/01…08`, report |

Downstream job graph (`step2.sh`): `Pipeline_plot → Decontamination → SingleSample`, then
`GOKEGG / SingleR / Monocle / CellChat` in parallel; `step4.sh` renders the report.

## Downstream modules

| # | Script | Key parameters | Output |
|---|---|---|---|
| 1 | `Pipeline_plot.R` | `min.cells=3`, `min.features=200`, 2000 HVGs, `RunPCA` 50 PCs, `ElbowPlot` 15 | `02.Normalize`, `03.HvgPCA` |
| 2 | `Decontamination.R` | `decontX` (top 10% → `H-prob`) + `DoubletFinder`; keep `Singlet & L-prob` | `04.Decontamination` |
| 3 | `SingleSample.R` | `dims=1:10`, `resolution=0.5`, UMAP, `presto` markers | `04.sSample` |
| 4 | `GOKEGG.R` | `enrichGO` BP/CC/MF (top 10) + `enrichKEGG` per cluster, OrganismDB from `Org_list` | `05.GOKEGG` |
| 5 | `SingleR.R` | `BlueprintEncodeData` / `MouseRNAseqData`, `label.fine`, `de.method="wilcox"` | `06.SingleR` |
| 6 | `Monocle.R` | monocle3, `cluster_cells(resolution=1e-3)`, root = cluster 1 | `07.Monocle` |
| 7 | `CellChat.R` | human/mouse DB, `computeCommunProb`, `filterCommunication(min.cells=10)` | `08.CellChat` |

## Requirements

- **Cell Ranger 10.0.0**, Linux x86_64, ≥48 cores (the demo used 48 cores / 1000 GB `--localmem`, ~60 GiB peak RSS)
- **R 4.x** + Seurat, SeuratWrappers, glmGamPoi, DoubletFinder, celda, SingleR, scater, presto, monocle3,
  CellChat, clusterProfiler, DOSE, org.Hs.eg.db / org.Mm.eg.db, ggplot2, dplyr, argparse, data.table, stringr
- **Perl 5.x** for the ARF report engine; `wkhtmltopdf` / `pdftk` / `enca` are bundled in `DowAna/code/scRNA_arf/bin/program/`
- **10x Cloud token** at `~/.config/txg/credentials` — only for `cellranger annotate`

```bash
Rscript -e 'install.packages(c("Seurat","ggplot2","dplyr","argparse","data.table","stringr"))'
Rscript -e 'BiocManager::install(c("SingleR","scater","celda","glmGamPoi","clusterProfiler","DOSE","org.Hs.eg.db","org.Mm.eg.db"))'
Rscript -e 'devtools::install_github(c("immunogenomics/presto","chris-mcginnis-ucsf/DoubletFinder","jinworks/CellChat","cole-trapnell-lab/monocle3"))'
```

No lockfile is shipped; the scripts auto-install missing packages, so results match the original environment's versions.

## Usage

```bash
# 0) rewrite hardcoded paths (all scripts, sample.list and Cell Ranger metadata embed the original directory)
ROOT=$(pwd)
grep -rIl '/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline' . \
  | xargs sed -i "s#/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline#${ROOT}#g"

# 1) counting
cellranger count --id=run_count_1kpbmcs --fastqs=${ROOT}/Fastq/pbmc_1k_v3_fastqs --sample=pbmc_1k_v3 \
  --transcriptome=${ROOT}/References/refdata-gex-GRCh38-2024-A --create-bam true --localcores 48 --localmem 1000

# 2) cloud annotation (optional, needs token; skip freely)
cellranger annotate --id=run_annotate_1kpbmcs \
  --matrix=${ROOT}/run_count_1kpbmcs/outs/filtered_feature_bc_matrix.h5 \
  --cloupe=${ROOT}/run_count_1kpbmcs/outs/cloupe.cloupe --cell-annotation-model=auto

# 3) downstream: stage inputs -> render job scripts -> run -> report -> assemble
bash DowAna/code/dataprepare.sh
bash DowAna/code/Runprepare.sh -F DowAna/sample.list -O DowAna/Res
bash DowAna/code/step2.sh      -F DowAna/sample.list -O DowAna/Res
bash DowAna/code/step4.sh
bash DowAna/Pro_output.sh
```

- Change `Rscript_path` in `Runprepare.sh`, and `up_dir` / `down_dir` / `out_dir` + `sampleNames` in `Pro_output.sh`.
- Already have `outs/`? Run steps 3–5 only — `dataprepare.sh` is the single entry point.
- Re-run one module: delete its `DowAna/Res/code/<Step>_<sample>.sh.sign` and start `step2.sh` again.

## Configuration

`DowAna/sample.list` — tab-separated, one row per library:

| Column | Meaning |
|---|---|
| `Samplename` | must equal the Cell Ranger `--id` |
| `libname` | library id used in result folder names |
| `datapath` | staged input root, i.e. `upResult/<sample>` |
| `organism` | `Human` / `Mouse` / … → OrgDb + KEGG code via `code/dependence/Org_list` |
| `step` | module mask: `1` plot, `2` decontamination, `3` clustering, `4` GO/KEGG, `5` SingleR, `6` Monocle, `7` CellChat (`1234567` = all) |

Other config: `DowAna/Project.info` (report project id / title), `code/dependence/Org_list` (16 organisms),
`code/dependence/{BlueprintEncodeData,MouseRNAseqData}.rds` (SingleR references — placeholders here, fetch from `celldex`).

## Output structure

```
run_count_1kpbmcs/outs/            # filtered/raw_feature_bc_matrix, metrics_summary.csv, web_summary.html, bam, cloupe
run_annotate_1kpbmcs/outs/         # cell_types.csv, cell_annotation_results.json.gz
DowAna/upResult/<sample>/          # 04.Matrix/FilterMatrix + 07.report/*.csv
DowAna/Res/{Cell,QC,Mapping}.xls   # per-sample QC / mapping / cell-count tables
DowAna/Res/code/                   # generated <Step>_<sample>.sh + .sh.sign markers
DowAna/Res/<sample>/               # 01.Data_report 02.Normalize 03.HvgPCA 04.Decontamination 04.sSample
                                   # 05.GOKEGG 06.SingleR 07.Monocle 08.CellChat
DowAna/<sample>_HTML/HTML_report/report/   # report.html + report_en.pdf + report_cn.pdf
Project_output/<sample>/ + <sample>.md5    # assembled deliverable (Pro_output.sh)
```

## Notes

1. Hardcoded absolute paths: `dataprepare.sh`, `Runprepare.sh`, `step4.sh`, `sample.list`, `Pro_output.sh` and the Cell
   Ranger metadata all reference the original tree — do the step-0 rewrite first.
2. `cellranger annotate` is not reproducible offline (10x Cloud service + token path in `_invocation`); nothing downstream needs it.
3. `step4.sh` still contains a no-op `sed` for the template path `/oldhome/luow/STProject_2023_analysis/...`.
4. 14 symlinks are kept as symlinks; one points at a 4.2 GB BAM in the original tree, so it dangles in a fresh clone.
5. `References/` ships only the human reference (`refdata-gex-GRCh38-2024-A`) used by this run.
6. Bundled `wkhtmltopdf` / `pdftk` / `enca` keep their upstream licences.

## Data and contact

Demo data: 10x Genomics public PBMC 1k v3. Reference: 10x prebuilt `refdata-gex-GRCh38-2024-A`. No licence is
granted for this repository yet — add a `LICENSE` before reuse.

Questions or suggestions: open an Issue / PR · oyjh417701@163.com
