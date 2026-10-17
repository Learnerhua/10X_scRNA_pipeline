# 10X单细胞数据分析流程

**欧阳继华**

**2025年3月**



------

[TOC]

------



##  1 Cell Ranger安装

进入[**Cell Ranger下载中心**](https://www.10xgenomics.com/support/software/cell-ranger/downloads#download-links)下载最新版本的Cell Range软件。

<img src="D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\CellRange_download.png" style="zoom: 33%;" />

将相关路径添加至环境变量中：

```bash
export PATH=/opt/cellranger-x.y.z:$PATH
```

运行出现如下界面即表示程序成功安装：

<img src="D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\CellRange_install.png" style="zoom: 50%;" />



## 2 准备参考基因组数据

### 2.1 预建参考基因组

对于常见物种（**人，小鼠，大鼠**），10X官方提供了预先构建好的参考基因基因组，直接在[**下载中心**](https://www.10xgenomics.com/support/software/cell-ranger/downloads#reference-downloads)下载解压即可使用。

<img src="D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\Human_ref_download.png" style="zoom: 50%;" />

### 2.2 自建参考基因组

10X官方同样支持用户自行构建参考基因组，并给出了[**自建流程**](https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-mr)。

这里以**斑马鱼**参考基因组构建为例进行构建流程的展示。

1. 在**[ENSEMBL](https://www.ensembl.org/index.html)**或其他基因组数据库下载斑马鱼的基因组和GTF文件

```bash
wget -c https://ftp.ensembl.org/pub/release-115/fasta/danio_rerio/dna/Danio_rerio.GRCz11.dna.primary_assembly.fa.gz

wget -c https://ftp.ensembl.org/pub/release-115/gtf/danio_rerio/Danio_rerio.GRCz11.115.gtf.gz
```

> [!WARNING]
>
> **基因组注释文件只支持GTF格式，不支持GFF格式，如果只有GFF可以借助其他工具进行转换成GTF**

2. 对GTF文件进行过滤，筛选出需要的基因类型。

```bash
cellranger mkgtf \
     Danio_rerio.GRCz11.115.gtf \
     Danio_rerio.GRCz11.115.filtered.gtf \
     --attribute=gene_biotype:protein_coding
```

3. 使用过滤后的GTF文件和基因组数据来构建基因组参考文件。

```bash
cellranger mkref \
  --genome Drerio_genome \
  --fasta Danio_rerio.GRCz11.dna.primary_assembly.fa \
  --genes Danio_rerio.GRCz11.115.filtered.gtf \
  --nthreads 60 \
  --memgb 1000
```

搭建好的参考基因组格式如下：

<img src="D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\ref_genome_mkref.png" style="zoom: 50%;" />



## 3 准备测序数据文件

### 3.1 由BCL文件转fastq文件

**10x官方**开发了 `cellranger mkfastq`工具，这是一个包装了 Illumina 的 **bcl2fastq** 程序的管道，能够让使用者方便快捷地将Illumina测序产生的BCL文件转换成下游分析可识别的fastq文件，[参考页面](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/inputs/cr-mkfastq)。

1. 首先需要安装Illumina的**bcl2fastq** 程序

方法一：根据Illumina提供的官方教程安装，先去[软件中心](https://support.illumina.com/downloads/bcl2fastq-conversion-software-v2-20.html)下载对应安装包，然后再根据安装[指导文件](https://support.illumina.com/content/dam/illumina-support/documents/documentation/software_documentation/bcl2fastq/bcl2fastq2-v2-20-software-guide-15051736-03.pdf)进行安装。

这种方法只提供rpm安装和源码安装两种方式，对于非CentOS系统安装不太友好。

方法二（**推荐**）：使用conda安装，参考命令：

```bash
conda install -c bih-cubi bcl2fastq2
bcl2fastq -v
```

2. 准备好所需BCL相关文件。这里使用教程中的测序数据：

```bash
wget -c https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-1.2.0.tar.gz
wget https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-simple-1.2.0.csv
```
下载解压后的文件格式如下：

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\BCL_download.png)


3. 运行`cellranger mkfastq`产生fastq文件

```bash
cellranger mkfastq --id=tiny-bcl \
             --run=/path/to/tiny_bcl \
             --csv=cellranger-tiny-bcl-simple-1.2.0.csv
```

最终产生的fastq文件在以输入id指定的文件夹内，具体位置如图：

![image-20260303150254103](C:\Users\oyjh\AppData\Roaming\Typora\typora-user-images\image-20260303150254103.png)

### 3.2 直接使用已有的fastq文件

如果得到的数据是现成的fastq数据（例如来自公共数据库），则无需进行转化，可以直接使用。

10X官方提供了[**官方的测序数据库**](https://www.10xgenomics.com/datasets)，在这里使用其中的[**1k PBMCs**](https://www.10xgenomics.com/datasets/1-k-pbm-cs-from-a-healthy-donor-v-3-chemistry-3-standard-3-0-0)数据集进行使用。

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\1k_PBMC_download.png)

直接下载fastq文件用于后续分析流程。

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\1k_PBMC_download2.png)



## 4 运行cellranger count

使用**`cellranger count`**参数进行上游分析，参考命令如下：

```bash
cellranger count \
	--id=run_count_1kpbmcs \
	--fastqs=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/Fastq/pbmc_1k_v3_fastqs \
	--sample=pbmc_1k_v3 \
	--create-bam true \
	--localcores 48 \
	--localmem 1000 \
	--transcriptome=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/References/refdata-gex-GRCh38-2024-A
```

官方文档给出了[所有参数及其含义](https://www.10xgenomics.com/support/software/cell-ranger/latest/resources/cr-command-line-arguments)，这里用到的主要参数说明：

| 参数              | 作用                                                         |
| ----------------- | ------------------------------------------------------------ |
| `--id`            | 指定运行的唯一标识符（ID），该 ID 用作输出目录的名称。       |
| `--fastqs`        | 指定包含 FASTQ 文件的目录路径，Cell Ranger 会从该目录读取输入的 FASTQ 文件。 |
| `--sample`        | 指定要使用的样本名，用于从多个样本的 FASTQ 文件中选择特定的样本。 |
| `--create-bam`    | 启用或禁用 BAM 文件生成。设置为 `true` 会生成 BAM 文件。     |
| `--localcores`    | 指定本地计算时要使用的最大 CPU 核心数，用于并行处理。        |
| `--localmem`      | 指定本地计算时要使用的最大内存，单位为 GB。                  |
| `--transcriptome` | 指定包含转录组参考数据的文件夹路径，用于基因表达量计数。     |

运行时间取决于数据量大小，上述的pbmc_1k_v3数据集运行时间约为**30min**。运行成功后输出结果的目录如下：

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\1k_PBMC_output.png)

> [!IMPORTANT]
>
> `cellranger count`也提供了**`--force-cells`**参数用于强制指定生成的细胞数量



## 5 输出文件

官方文档中给出了`cellranger count`程序的[输出内容](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/outputs/cr-outputs-gex-overview)，同时具体解释了[各个输出文件](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/outputs/cr-outputs-overview)的含义。

| 文件/文件夹                     | 描述                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| `analysis/`                     | 包含基于图的聚类结果和 K-means 聚类（2–10 类）；簇间差异基因表达分析；以及 PCA、t-SNE 和 UMAP 等降维分析结果的文件夹。 |
| `cloupe.cloupe`                 | 用于 Loupe Browser 的可视化与分析文件。                      |
| `filtered_feature_bc_matrix/`   | 仅包含检测到的、与细胞相关的条形码（barcode），采用 MEX 格式。矩阵中的每个元素表示某个特征（行）与某个条形码（列）对应的 UMI 数量。该文件可作为第三方分析软件的输入，用于处理条形码-特征矩阵（例如过滤异常细胞、运行降维分析、进行基因表达归一化等）。 |
| `filtered_feature_bc_matrix.h5` | 与 `filtered_feature_bc_matrix/` 内容相同，但为 HDF5 格式。  |
| `metrics_summary.csv`           | 以 CSV 格式保存的运行结果汇总指标文件，详见基因表达指标说明页面。 |
| `molecule_info.h5`              | 包含所有具有有效条形码、有效 UMI，并被高置信度分配到某个基因或 Feature Barcode 的分子级别信息。该文件是运行 `cellranger aggr` 所需的输入文件。 |
| `possorted_genome_bam.bam`      | 经过基因组和转录组比对后按基因组位置排序的 BAM 文件（已建立索引），包含已比对和未比对的 reads，并带有条形码注释信息。 |
| `possorted_genome_bam.bam.bai`  | `possorted_genome_bam.bam` 的索引文件。如果参考转录组来源的基因组染色体非常长（>512 Mbp），Cell Ranger v7.0 及以上版本会生成 `possorted_genome_bam.bam.csi` 索引文件。 |
| `raw_feature_bc_matrix/`        | 包含所有检测到的条形码（包括非细胞条形码），采用 MEX 格式。矩阵中的每个元素表示某个特征（行）与某个条形码（列）对应的 UMI 数量。 |
| `raw_feature_bc_matrix_h5`      | 与 `raw_feature_bc_matrix/` 内容相同，但为 HDF5 格式。       |
| `web_summary.html`              | 以 HTML 格式展示的运行结果汇总指标与图表页面，详见 count 的 web summary 页面说明。 |

上述文件中中最重要的是`filtered_feature_bc_matrix/`和`filtered_feature_bc_matrix.h5`，这是上游分析得到的主要结果，<font color="red">**作为下游分析的输入的表达矩阵文件**。</font>具体可查看[官网相关页面](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/outputs/cr-outputs-matrices)。

`web_summary.html`是上游分析结果用于展示的html文件。可以直接使用浏览器打开，效果如下：

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\cellranger_count_html.png)

.cloupe文件是一个可以用10X官方可视化软件**Loupe Browser**打开的可视化分析文件，可以按照[**教程**](https://www.10xgenomics.com/support/software/loupe-browser/latest/tutorials/introduction/lb-sc-interface-and-navigation)对该文件进行探索。

> Loupe Browser 是一款功能强大的可视化软件，为用户提供直观易用的功能，用于探索和分析 10x Genomics Chromium 和 Visium 数据。你还可以使用 LoupeR 软件包将 Seurat 对象转换为 Loupe Browser 文件格式。

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\Loupe_Browser_nterface.png)

> [!NOTE]
>
> 也可以使用10X提供的[loupeR包](https://github.com/10XGenomics/loupeR)在R中将seurat对象储存为.loupe文件再在Loupe Browser中进行可视化分析，这一方法<font color="red">**仅适用于10X来源的数据**</font>



## 6 细胞自动注释

cellranger在v9版本引入了[细胞自动注释功能](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/running-pipelines/cr-cell-annotation-pipeline)，可基于`cellranger count`的结果使用`cellranger annotate`对细胞进行自动注释。

> [!IMPORTANT]
>
> 在运行该命令前需要在[10X云分析网站](https://cloud.10xgenomics.com/account/security)获取用户token令牌，复制该令牌，随后在命令行中敲入`cellranger cloud auth setup`后输入令牌进行验证

参考命令如下：

```bash
cellranger annotate --id=run_annotate_1kpbmcs \
    --matrix=run_count_1kpbmcs/outs/filtered_feature_bc_matrix.h5 \
    --cloupe=run_count_1kpbmcs/outs/cloupe.cloupe \
    --cell-annotation-model=auto \
    --localcores 48 \
    --localmem 1000
```

使用`cellranger cloud annotation models`命令可查看支持的模型，目前仅支持对人或小鼠的数据进行自动注释，参数值直接用auto即可。

输出结果如下：

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\celllranger_annotate.png)

其中网页报告文件web_summary_cell_types.html的展示效果如下：

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\annotate_html.png)



官网给出了全部[输出结果解释](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/outputs/cr-cell-annotation-outputs)，虽然该注释流程不能完全代替更加精准的手动注释流程，但也具有一定的参考价值。

## 7 使用示例

本教程的运行使用示例在fat02服务器，路径如下：

```bash
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline
```



## 8 下游分析流程搭建

需要将10X上游分析结果与已有的单细胞C4流程下游报告对接，因此要将上游数据整理成已有流程可识别的格式。

已有下游脚本和文件如下：
![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\C4_code.png)

### 8.1 修改dataprepare.sh

该脚本主要负责从上游分析结果提取下游分析数据，需要大改，修改之后如下：

```bash
#!/bin/bash
set -euxo pipefail

input_dir=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline
out_dir=${input_dir}/DowAna/upResult
sampleNames=(run_count_1kpbmcs)

for samplename in ${sampleNames[@]};do

        if [ ! -d "${out_dir}/${samplename}/04.Matrix/FilterMatrix" ];then
                mkdir -p "${out_dir}/${samplename}/04.Matrix/FilterMatrix"
        fi

        cp -r ${input_dir}/${samplename}/outs/filtered_feature_bc_matrix/* ${out_dir}/${samplename}/04.Matrix/FilterMatrix

        if [ ! -d "${out_dir}/${samplename}/07.report" ];then
                mkdir -p "${out_dir}/${samplename}/07.report"
        fi

        perl -pe 's/"([^"]+)"/($x = $1) =~ s|,||g; $x/ge' ${input_dir}/${samplename}/outs/metrics_summary.csv | perl -F"," -alne 'if ($.==1){@line1=@F}else{$i=0;foreach (@line1){print "$line1[$i]\t$F[$i]";$i++}}' | egrep -e "Estimated Number of Cells|Mean Reads per Cell|Median Genes per Cell|Total Genes Detected|Median UMI Counts per Cell" > ${out_dir}/${samplename}/07.report/1.cell_report.csv

        perl -pe 's/"([^"]+)"/($x = $1) =~ s|,||g; $x/ge' ${input_dir}/${samplename}/outs/metrics_summary.csv | perl -F"," -alne 'if ($.==1){@line1=@F}else{$i=0;foreach (@line1){print "$line1[$i],$F[$i]";$i++}}' | egrep "Reads Mapped Confidently to Genome|Reads Mapped Confidently to Intergenic Regions|Reads Mapped Confidently to Intronic Regions|Reads Mapped Confidently to Exonic Regions" > ${out_dir}/${samplename}/07.report/5.anno_report.csv

        perl -pe 's/"([^"]+)"/($x = $1) =~ s|,||g; $x/ge' ${input_dir}/${samplename}/outs/metrics_summary.csv | perl -F"," -alne 'if ($.==1){@line1=@F}else{$i=0;foreach (@line1){print "$line1[$i],$F[$i]";$i++}}' | egrep "Number of Reads|Valid Barcodes|Q30 Bases in Barcode|Q30 Bases in RNA Read|Q30 Bases in UMI" | perl -F, -ape 'if($.==1){$v=$F[1]} elsif($.==2){$F[1]=int($v*$F[1]/100+0.5); $_=join(",",@F)."\n"}' > ${out_dir}/${samplename}/07.report/3.cDNA_sequencing_report.csv

done
```

运行该脚本会将上游分析的结果提取至upResult目录中。

### 8.2 修改Getinfo.R

该脚本负责根据相关统计指标提取数据，用于后续展示在下游报告中，由于相关指标的提取字段发生了变化，因此该脚本需要修改相关的数据提取字段。

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\getinfo_1.png)

```R
table1 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Number of Reads" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Valid Barcodes" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Q30 Bases in Barcode" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Q30 Bases in RNA Read" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f5= system(command= paste0('grep -i "Q30 Bases in UMI" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
```

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\getinfo_2.png)

```R
table2 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Reads Mapped Confidently to Genome" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Reads Mapped Confidently to Exonic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Reads Mapped Confidently to Intronic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Reads Mapped Confidently to Intergenic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
```

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\getinfo_3.png)

```R
table3 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Estimated Number of Cells" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Mean Reads per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Median Genes per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Total Genes Detected" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f5= system(command= paste0('grep -i "Median UMI Counts per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
```

### 8.3 修改Pipeline_plot.R脚本

10X和华大生成的MEX文件格式并不完全一致，主要体现在features.tsv.gz文件上，华大的基因名在第一行，10X在第二行，因此需要修改读入该数据时用到的参数，这一步骤在Pipeline_plot.R脚本中，修改方法如下：
![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\pipeline_plot.png)

将`gene.column`参数的值由1改成2即可



修改完上述3个脚本后按原先流程继续分析即可顺利产出报告。



### 8.4 修改报告相关文件

为了使报告中的内容与10X技术保持一致，需要对报告中的许多内容进行修改，相应的，需要修改code目录下的文件，包括：

```
code/Pipeline_scRNA_arf.pl
code/scRNA_arf/arf_demo/
code/scRNA_arf/resource_demo/
```

**本步骤主要借助AI智能体完成（workbuddy）,一些技术图片文档可参考华大官网教程。**

修改好的文件已经统一存放在下面的位置：

```
D:\Work\KMHD\Analysis\10X_scRNA_pipeline\报告测试\最终修改文件
```

![](D:\Work\KMHD\Analysis\10X_scRNA_pipeline\pipeline_images\report.png)

将上述文件替换完成后直接重新运行step4步骤即可产出报告。



**修改完成后，下游分析的流程与已有的华大的流程完全相同**