# 10X-scRNA

<p align="center">
  <a href="https://www.10xgenomics.com/support/software/cell-ranger"><img src="https://img.shields.io/badge/Cell%20Ranger-10.0.0-00A1DE.svg" alt="Cell Ranger"></a>
  <a href="https://www.r-project.org"><img src="https://img.shields.io/badge/R-4.x-276DC3.svg?logo=r&logoColor=white" alt="R"></a>
  <a href="https://www.kernel.org"><img src="https://img.shields.io/badge/Platform-Linux%20x86__64-FCC624.svg?logo=linux&logoColor=black" alt="Platform: Linux"></a>
  <a href="https://www.10xgenomics.com/datasets"><img src="https://img.shields.io/badge/Data-10x%20PBMC%201k%20v3-green" alt="Data: 10x PBMC 1k v3"></a>
</p>

**Cell Ranger 10 定量 + Seurat 下游分析 + 中英文双语 HTML/PDF 报告** · [English](README.md)

面向 10x Genomics 数据的单细胞转录组全流程：`cellranger count` → 可选 `cellranger annotate` → 自建 Seurat 下游分析
→ 中英文 HTML + PDF 报告。

📖 **`10X_scRNA_SOP.md`** —— 本流程的中文 SOP 操作手册：Cell Ranger 安装、参考基因组准备（预建参考与自建 `mkref`）、
测序数据准备（BCL 转 fastq）、运行 `cellranger count`、输出文件解读、`cellranger annotate` 细胞注释，
以及如何把下游脚本（`dataprepare.sh`、`Getinfo.R`、`Pipeline_plot.R`、报告相关文件）适配到新项目。

本仓库同时是一份可对照的样例：每个目录都是演示样本 `run_count_1kpbmcs`（人 PBMC 1k v3，11 个 cluster）的真实输出，
各步骤的目录结构与文件名即按其实际产物呈现。

> **⚠️ 大于 1 MiB 的文件已替换为零字节占位文件。** 共 153 个（STAR 索引、基因组 FASTA/GTF、FASTQ、BAM、
> `.RDS`、矩阵 `.h5`、报告 PDF），用于把仓库从 65 GB 压到 210 MB。脚本从未被替换。恢复方式：
>
> ```bash
> find . -type f -size 0 -printf '%P\n' > placeholders.txt   # 153 条
> while read -r f; do cp -a "/path/to/full_dataset/$f" "./$f"; done < placeholders.txt
> ```

## 流程

| 阶段 | 工具 | 主要输出 |
|---|---|---|
| 定量 | `cellranger count --create-bam true --localcores 48 --localmem 1000`，STAR 比对 `refdata-gex-GRCh38-2024-A` | `run_count_1kpbmcs/outs/` |
| 注释（可选） | `cellranger annotate --cell-annotation-model=auto`（需 10x Cloud token） | `run_annotate_1kpbmcs/outs/cell_types.csv` |
| 下游分析 | Seurat / R，由 `.sh.sign` 标记文件调度 | `DowAna/Res/<sample>/01…08`、报告 |

下游任务图（`step2.sh`）：`Pipeline_plot → Decontamination → SingleSample`，随后 `GOKEGG / SingleR / Monocle /
CellChat` 并行；`step4.sh` 负责渲染报告。

## 下游模块

| # | 脚本 | 关键参数 | 输出 |
|---|---|---|---|
| 1 | `Pipeline_plot.R` | `min.cells=3`、`min.features=200`、2000 高变基因、`RunPCA` 50 PC、`ElbowPlot` 15 | `02.Normalize`、`03.HvgPCA` |
| 2 | `Decontamination.R` | `decontX`（最高 10% 记 `H-prob`）+ `DoubletFinder`；保留 `Singlet & L-prob` | `04.Decontamination` |
| 3 | `SingleSample.R` | `dims=1:10`、`resolution=0.5`、UMAP、`presto` 计算 Marker | `04.sSample` |
| 4 | `GOKEGG.R` | 逐 cluster `enrichGO` BP/CC/MF（各取前 10）+ `enrichKEGG`，物种库由 `Org_list` 决定 | `05.GOKEGG` |
| 5 | `SingleR.R` | `BlueprintEncodeData` / `MouseRNAseqData`、`label.fine`、`de.method="wilcox"` | `06.SingleR` |
| 6 | `Monocle.R` | monocle3、`cluster_cells(resolution=1e-3)`、根细胞取 cluster 1 | `07.Monocle` |
| 7 | `CellChat.R` | 人/鼠数据库、`computeCommunProb`、`filterCommunication(min.cells=10)` | `08.CellChat` |

## 运行环境

- **Cell Ranger 10.0.0**，Linux x86_64，≥48 核（演示用 48 核 / `--localmem 1000`，RSS 峰值约 60 GiB）
- **R 4.x** + Seurat、SeuratWrappers、glmGamPoi、DoubletFinder、celda、SingleR、scater、presto、monocle3、
  CellChat、clusterProfiler、DOSE、org.Hs.eg.db / org.Mm.eg.db、ggplot2、dplyr、argparse、data.table、stringr
- **Perl 5.x** 用于 ARF 报告引擎；`wkhtmltopdf` / `pdftk` / `enca` 已内置在 `DowAna/code/scRNA_arf/bin/program/`
- **10x Cloud token**，路径 `~/.config/txg/credentials` —— 仅 `cellranger annotate` 需要

```bash
Rscript -e 'install.packages(c("Seurat","ggplot2","dplyr","argparse","data.table","stringr"))'
Rscript -e 'BiocManager::install(c("SingleR","scater","celda","glmGamPoi","clusterProfiler","DOSE","org.Hs.eg.db","org.Mm.eg.db"))'
Rscript -e 'devtools::install_github(c("immunogenomics/presto","chris-mcginnis-ucsf/DoubletFinder","jinworks/CellChat","cole-trapnell-lab/monocle3"))'
```

仓库不提供 lockfile；脚本会自动安装缺失的包，因此结果对应原环境当时的包版本。

## 使用方法

```bash
# 0) 改写硬编码路径（脚本、sample.list 与 Cell Ranger 元信息都内嵌原始目录）
ROOT=$(pwd)
grep -rIl '/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline' . \
  | xargs sed -i "s#/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline#${ROOT}#g"

# 1) 定量
cellranger count --id=run_count_1kpbmcs --fastqs=${ROOT}/Fastq/pbmc_1k_v3_fastqs --sample=pbmc_1k_v3 \
  --transcriptome=${ROOT}/References/refdata-gex-GRCh38-2024-A --create-bam true --localcores 48 --localmem 1000

# 2) 云端注释（可选，需 token，可直接跳过）
cellranger annotate --id=run_annotate_1kpbmcs \
  --matrix=${ROOT}/run_count_1kpbmcs/outs/filtered_feature_bc_matrix.h5 \
  --cloupe=${ROOT}/run_count_1kpbmcs/outs/cloupe.cloupe --cell-annotation-model=auto

# 3) 下游：整理输入 -> 生成任务脚本 -> 执行 -> 出报告 -> 汇总交付
bash DowAna/code/dataprepare.sh
bash DowAna/code/Runprepare.sh -F DowAna/sample.list -O DowAna/Res
bash DowAna/code/step2.sh      -F DowAna/sample.list -O DowAna/Res
bash DowAna/code/step4.sh
bash DowAna/Pro_output.sh
```

- 需修改 `Runprepare.sh` 中的 `Rscript_path`，以及 `Pro_output.sh` 中的 `up_dir` / `down_dir` / `out_dir` 与 `sampleNames`
- 已有 `outs/`？只跑第 3–5 步即可，入口统一为 `dataprepare.sh`
- 重跑单个模块：删掉 `DowAna/Res/code/<Step>_<sample>.sh.sign` 后重新启动 `step2.sh`

## 配置

`DowAna/sample.list` —— 制表符分隔，一行一个样本文库：

| 列 | 含义 |
|---|---|
| `Samplename` | 必须等于 Cell Ranger 的 `--id` |
| `libname` | 文库 id，用于结果目录命名 |
| `datapath` | 整理后的输入根目录，即 `upResult/<sample>` |
| `organism` | `Human` / `Mouse` / … → 经 `code/dependence/Org_list` 决定 OrgDb 与 KEGG 物种码 |
| `step` | 模块掩码：`1` 作图、`2` 去污染、`3` 聚类、`4` GO/KEGG、`5` SingleR、`6` Monocle、`7` CellChat（`1234567` 全开） |

其他配置：`DowAna/Project.info`（报告项目号 / 标题）、`code/dependence/Org_list`（16 个物种）、
`code/dependence/{BlueprintEncodeData,MouseRNAseqData}.rds`（SingleR 参考数据，本仓库为占位文件，需从 `celldex` 获取）。

## 输出结构

```
run_count_1kpbmcs/outs/            # filtered/raw_feature_bc_matrix、metrics_summary.csv、web_summary.html、bam、cloupe
run_annotate_1kpbmcs/outs/         # cell_types.csv、cell_annotation_results.json.gz
DowAna/upResult/<sample>/          # 04.Matrix/FilterMatrix + 07.report/*.csv
DowAna/Res/{Cell,QC,Mapping}.xls   # 每样本质控 / 比对 / 细胞数汇总表
DowAna/Res/code/                   # 生成的 <Step>_<sample>.sh 与 .sh.sign 标记
DowAna/Res/<sample>/               # 01.Data_report 02.Normalize 03.HvgPCA 04.Decontamination 04.sSample
                                   # 05.GOKEGG 06.SingleR 07.Monocle 08.CellChat
DowAna/<sample>_HTML/HTML_report/report/   # report.html + report_en.pdf + report_cn.pdf
Project_output/<sample>/ + <sample>.md5    # 汇总交付目录（Pro_output.sh）
```

## 注意事项

1. 绝对路径硬编码：`dataprepare.sh`、`Runprepare.sh`、`step4.sh`、`sample.list`、`Pro_output.sh` 与 Cell Ranger
   元信息都指向原始目录，动手前先执行第 0 步改写。
2. `cellranger annotate` 无法离线复现（依赖 10x Cloud 服务与 `_invocation` 中的 token 路径），下游分析不依赖它。
3. `step4.sh` 中还留有一条针对模板项目路径 `/oldhome/luow/STProject_2023_analysis/...` 的空操作 `sed`。
4. 14 个符号链接按链接保留，其中一个指向原始树中 4.2 GB 的 BAM，新克隆下为悬空链接。
5. `References/` 仅保留本次运行所用的人类参考（`refdata-gex-GRCh38-2024-A`）。
6. 内置的 `wkhtmltopdf` / `pdftk` / `enca` 遵循各自上游许可。

## 数据与联系

演示数据：10x Genomics 公开 PBMC 1k v3。参考基因组：10x 预构建 `refdata-gex-GRCh38-2024-A`。本仓库暂未授予许可，
复用前请先添加 `LICENSE`。

问题或建议：提交 Issue / PR · oyjh417701@163.com
