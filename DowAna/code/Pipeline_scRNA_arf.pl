#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my ($indir,$outdir,$help);
my ($step,$bin,$sample,$pinfo);
GetOptions(
        "help|h:s"=>\$help,
        "indir:s"=>\$indir,
        "pinfo:s"=>\$pinfo,
        "outdir:s"=>\$outdir,
        "sample:s"=>\$sample,
        "bin:s"=>\$bin,
        "step:s"=>\$step,
        );
chomp ($outdir||=`pwd`);
chomp ($indir||=`pwd`);
$bin||=50;
$step||="1234567";
die &usage if (defined $help);
die &usage unless (defined $sample && defined $pinfo);

my $arf_dir="$outdir/HTML_report/arf";           system ("mkdir -m 755 -p $arf_dir") unless (-d "$arf_dir");
my $IDBiotech_result="$outdir/HTML_report/IDBiotech_result"; system ("mkdir -m 755 -p $IDBiotech_result") unless (-d "$IDBiotech_result");
my $resource="$outdir/HTML_report/resource";     system ("mkdir -m 755 -p $resource") unless (-d "$resource");

my $nfigure = 1;
my $ntable = 1;
my $nreference =1;
my ($arf_en,$arf_cn);
$arf_cn="format = arf1.0\nlanguage = CN\n\n";
$arf_en="format = arf1.0\nlanguage = EN\n\n";

### 技术简介 ###
$arf_cn.="\%result\n\@title\n技术简介\n\@paragraph\n本项目使用10X Genomics开发的单细胞组学技术（Chromium）\\reference{$nreference}，分析目标样本的单细胞水平的转录表达模式，全流程概览如图1所示。
实验流程：
1. 样本处理及质检：对目标组织样本进行细胞/细胞核悬液制备，并进行细胞/细胞核悬液质控评估；
2. 单细胞分离及mRNA分子的捕获：对制备合格的细胞/细胞核悬液通过Chromium的液滴微流控设备，完成GEM（Gel bead in Emulsion）的生成，实现单个细胞的分离，GEM生成后破乳回收mRNA分子，并对mRNA分子进行逆转录合成cDNA；
3. 文库制备及测序：cDNA合成后构建测序文库并完成测序；
数据分析：
针对下机数据进行质控，并完成全套分析，最终得到目标样本细胞/细胞核水平表达的基因信息。\n
\@figure\nnumber = $nfigure\ntitle = \"单细胞组学技术流程图\"\nfile = <url = resource/scRNA_analysis_pipeline_cn.png; label = \"单细胞组学技术流程图\">\nsize = <width = 800; height = 400>\ndesc = \" \"\n\n";
$arf_en.="\%result\n\@title\nTechnology Introduction\n\@paragraph\nThis project uses the single-cell omics technology (Chromium)\\reference{$nreference}, which was developed by 10X Genomics to analyze gene expression patterns at the single cell level from target samples.
The experimental processes are as follows:
1. Sample processing and quality inspection: Target tissue samples were prepared with cell/nuclear suspension and evaluated for cell/nuclear suspension quality control.
2. Isolation of single cells and capture of mRNA molecules: The qualified cell/nuclear suspension was processed by the droplet microfluidic device of Chromium to generate GEMs (Gel beads in Emulsion) and realize the separation of single cells. mRNA molecules were recovered by demulsification after GEM generation, and cDNA was synthesized by reverse transcription of mRNA molecules.
3. Library preparation and sequencing: The cDNA library was constructed and sequenced after synthesis.
Data analysis: 
quality control is performed for sequenced data, and a full set of bioinformatic analyses are conducted to obtain the gene information expressed at the cell/nucleus level of the target sample. \n
\@figure\nnumber = $nfigure\ntitle = \"Flow chart of single cell omics technology\"\nfile = <url = resource/scRNA_analysis_pipeline_cn.png; label = \"Flow chart of single cell omics technology\">\nsize = <width = 800; height = 400>\ndesc = \" \"\n\n";
$nfigure++;
$nreference++;


### 项目信息 ###
if(-e "$indir/Project_information.txt"){
    system("cp $indir/Project_information.txt $IDBiotech_result");
}else{
    die "Please check file <Project_information.txt>";
}
my @samples=split/,|\s+/,$sample;
my $sample_num=@samples;
my $tmp_format_t0; # this is by column to set
# can be fixed
foreach my $jj(1..2){
    $tmp_format_t0.="format = <field = $jj; type = string; align =centre; desc = \"Sample\">\n";
}
$arf_cn.="\%result\n\@title\n项目信息\n\@paragraph\n本项目的信息见表$ntable。
\@table\nnumber = $ntable\ntitle = \"项目信息表\"\nfile = <url = IDBiotech_result/Project_information.txt>\n${tmp_format_t0}\n";
$arf_en.="\%result\n\@title\nProject Information\n\@paragraph\nInformations of this project are shown in Table$ntable.
\@table\nnumber = $ntable\ntitle = \"Project informations\"\nfile = <url = IDBiotech_result/Project_information.txt>\n${tmp_format_t0}\n";
$ntable++;


#===================================================================================================================================================================================
### 1.Analysize Result ###
# check files
if(-e "$indir/Mapping.xls"){
    system("cp $indir/Mapping.xls $IDBiotech_result");
}else{
    die "Please check file <Mapping.xls>";
}

if(-e "$indir/Cell.xls"){
    system("cp $indir/Cell.xls $IDBiotech_result");
}else{
    die "Please check file <Cell.xls>";
}

if(-e "$indir/QC.xls"){
    system("cp $indir/QC.xls $IDBiotech_result");
}else{
    die "Please check file <QC.xls>";
}

my $subtitle=1;
### 分析结果 ###
### 1.1 Filter ###
### QC ###
# To generate tables 
# foreach my $each(@samples){
#     # system ("mkdir -p $IDBiotech_result/$each/01.Filter");
#     system ("mkdir -m 755 -p $IDBiotech_result/$each/01.Filter") unless (-d "$IDBiotech_result/$each/01.Filter");
#     if(-e "$indir/$each/01.Filter/new_final_result.json"){
#         system ("perl /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/STOmics/bin/generate_filter_report_table.split.v3.pl $each $indir/$each/01.Filter/");
#         system ("cp $indir/$each/01.Filter/plot_200x200_saturation.png $IDBiotech_result/$each/01.Filter/plot_200x200_saturation.png");
#         system ("cp $indir/$each/01.Filter/*.xls $IDBiotech_result/$each/01.Filter/");
#     }else{
#         die "Please check if Filter of $each was totally completed !!! \n";
#     }
# }
# # add a head for acfilter.xls
# system ("paste /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/STOmics/resource_demo/table1_header.txt $IDBiotech_result/*/01.Filter/table1_qcfilter.xls > $IDBiotech_result/all_samples.table1_qcfilter.xls");

my $tmp_format_t1; # this is by column to set
# can be fixed
foreach my $jj(1..6){
    $tmp_format_t1.="format = <field = $jj; type = string; align =centre; desc = \"Sample\">\n";
}

$arf_cn.="\%result\n\@title\n测序结果\n\@paragraph\n
\@subtitle\nnumber = $subtitle\n下机数据质控\n\@paragraph\n测序数据下机后，会对read1和read2进行数据质控，read1为包含16bp cell barcode以及12bp UMI序列，read2为cDNA序列。 使用Cell Ranger (v10.0.0) 工具对read1和read2进行质控过滤， 过滤标准详见信息分析流程-下机数据质控，质控统计结果见表$ntable。
\@table\nnumber = $ntable\ntitle = \"下机数据质控统计结果\"\nfile = <url = IDBiotech_result/QC.xls>\n${tmp_format_t1}footnote = \"Sample: 样本名；\"\nfootnote = \"Number of Reads：测序的总reads数；\"\nfootnote = \"Valid Barcodes: Reads中的barcode在已知数据集中的比例；\"\nfootnote = \"Q30 Bases in Barcode：Barcode测序质量在Q30以上的碱基比例；\"\nfootnote = \"Q30 Bases in RNA Read: 插入RNA片段的测序质量在Q30以上的碱基比例；\"\nfootnote = \"Q30 Bases in UMI: UMI测序质量在Q30以上的碱基比例；\"\n";

$arf_en.="\%result\n\@title\nSequencing statistics\n\@paragraph\n
\@subtitle\nnumber = $subtitle\nQuality Control of Sequencing Data\n\@paragraph\nQuality control was processed on Read1 and Read2, Read1 contains 16bp cell barcode and 12bp UMI sequence, and Read2 is cDNA sequence. The Cell Ranger (v10.0.0) tool was used to filter Read1 and Read2 for quality control. The filtering standards are detailed in the information analysis process - Off-board Data Quality Control. The statistical results of quality control are shown in Table $ntable.
\@table\nnumber = $ntable\ntitle = \"Quality control results of sequencing data\"\nfile = <url = IDBiotech_result/QC.xls>\n${tmp_format_t1}footnote = \"Sample: Sample name;\"\nfootnote = \"Number of Reads: The total number of reads sequenced;\"\nfootnote = \"Valid Barcodes: Ratio of barcode in Reads to known data sets;\"\nfootnote = \"Q30 Bases in Barcode: The percentage of bases in Barcode with a mass value (Q=-10log(err rate)) greater than 30;\"\nfootnote = \"Q30 Bases in RNA Read: The percentage of bases in RNA Reads with a mass value (Q=-10log(err rate)) greater than 30;\"\nfootnote = \"Q30 Bases in UMI: The percentage of bases in UMI with a mass value (Q=-10log(err rate)) greater than 30.\"\n";
$ntable++;
$subtitle++;
$nreference++;

###  1.2 Alignment ###
my $tmp_format_t2; # this is by column to set
# can be fixed
foreach my $jj(1..5){
    $tmp_format_t2.="format = <field = $jj; type = string; align =centre; desc = \"Sample\">\n";
}
# system ("paste /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/STOmics/resource_demo/table2_header.txt $IDBiotech_result/*/01.Filter/table2_alignment.xls > $IDBiotech_result/all_samples.table2_alignment.xls");

$arf_cn.="\n\@subtitle\nnumber = $subtitle\n基因组比对\n\@paragraph\n使用STAR\\reference{$nreference}软件将Clean Reads与参考基因组进行比对，统计比对到外显子区、内含子区、基因间区等区域的reads数。比对结果见表$ntable。
\@table\nnumber = $ntable\ntitle = \"Clean Reads与参考基因组的比对结果统计\"\nfile = <url = IDBiotech_result/Mapping.xls>\n${tmp_format_t2}footnote = \"Sample: 样本名；\"\nfootnote = \"Reads Mapped to Genome：比对到基因组上的reads比例；\"\nfootnote = \"Reads Mapped to Exonic Regions：比对到外显子区域的reads比例；\"\nfootnote = \"Reads Mapped to Intronic Regions：比对到内含子区域的reads比例；\"\nfootnote = \"Reads Mapped to Intergenic Regions：比对到基因间区的reads比例；\"\n";

$arf_en.="\n\@subtitle\nnumber = $subtitle\nGenome Alignment\n\@paragraph\nSTAR\\reference{$nreference} was used to map clean reads to the reference genome, and the number of reads mapped to exon regions, intron regions and inter-genetic regions was counted. The statistical results are shown in Table$ntable.
\@table\nnumber = $ntable\ntitle = \"Statistics of Clean Reads aligned to the reference genome\"\nfile = <url = IDBiotech_result/Mapping.xls>\n${tmp_format_t2}footnote = \"Sample: Sample name;\"\nfootnote = \"Reads Mapped to Genome: The ratio of reads aligned to reference genome;\"\nfootnote = \"Reads Mapped to Exonic Regions: The ratio of reads aligned to exonic regions of reference genome;\"\nfootnote =\"Reads Mapped to Intronic Regions: The ratio of reads aligned to intronic regions of reference genome;\"\nfootnote =\"Reads Mapped to Intergenic Regions: The ratio of reads aligned to intergenic regions of reference genome.\"\n";
$ntable++;
$subtitle++;
$nreference++;

### 1.3 GeneExpMatrix and Cells ###
my $tmp_format_t3; # this is by column to set
# can be fixed
foreach my $jj(1..6){
    $tmp_format_t3.="format = <field = $jj; type = string; align =centre; desc = \"Sample\">\n";
}

# foreach my $each(@samples){
#     # system("mkdir -p $IDBiotech_result/$each/02.GeneExpMatrix");
#     system ("mkdir -m 755 -p $IDBiotech_result/$each/02.GeneExpMatrix") unless (-d "$IDBiotech_result/$each/02.GeneExpMatrix");
#     system("cp $indir/$each/02.GeneExpMatrix/lasso.final.gem.binstat $IDBiotech_result/$each/02.GeneExpMatrix");
# }
# system ("paste /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/STOmics/resource_demo/table3_header.txt $IDBiotech_result/*/01.Filter/table3_expression.xls > $IDBiotech_result/all_samples.table3_expression.xls");
# system ("cat /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/STOmics/resource_demo/table4_header.txt $IDBiotech_result/*/02.GeneExpMatrix/lasso.final.gem.binstat > $IDBiotech_result/all_samples.table4_binstat.xls");

$arf_cn.="\n\@subtitle\nnumber = $subtitle\n基因表达定量\n\@paragraph\n使用STARsolo\\reference{$nreference}软件，将比对到参考基因组唯一位置的reads (Uniquely Mapping Reads) 与基因的对应关系以及基因表达量(UMI数量)进行统计， 得到每个细胞基因捕获情况， 具体结果见表$ntable。
\@table\nnumber = $ntable\ntitle = \"基因捕获情况统计\"\nfile = <url = IDBiotech_result/Cell.xls>\n${tmp_format_t3}footnote = \"Sample: 样本名\"\nfootnote = \"Estimated Number of Cells：细胞数量估计；\"\nfootnote = \"Mean Reads per Cell：平均每个细胞中的reads数量；\"\nfootnote = \"Median Genes per Cell：平均每个细胞中的基因数；\"\nfootnote = \"Total Genes Detected：检测到的基因总数；\"\nfootnote = \"Median UMI Counts per Cell：平均每个细胞中UMI的数量。\"\n";

$arf_en.="\n\@subtitle\nnumber = $subtitle\nQuantification of Gene Expression\n\@paragraph\n Using STARsolo\\reference{$nreference} software, reads (Uniquely Mapping Reads) compared to the unique position of the reference genome were counted according to their corresponding relationship with genes and the amount of gene expression (UMI number) to obtain the gene capture situation of each cell. The detailed results were shown in $ntable.
\@table\nnumber = $ntable\ntitle = \"Statistics of Unique Mapping Reads aligned to the reference genome\"\nfile = <url = IDBiotech_result/Cell.xls>\n${tmp_format_t3}footnote = \"Sample: Sample name;\"\nfootnote = \"Estimated Number of Cells: Estimated Number of Cells;\"\nfootnote = \"Mean Reads per Cell: Mean Reads per Cell;\"\nfootnote =\"Median Genes per Cell: Median Genes per Cell;\"\nfootnote = \"Total Genes Detected: Total Genes Detected.\"\n";

$ntable++;


# $arf_cn.="\@paragraph\n在时空组学技术（STOmics）中，Bin是分析数据统计的基本单元。一个Bin表示一个固定大小的区域，区域内DNB表达量累加，区域间不重合，数字表示单边DNB 数量。时空芯片上每个DNB 在基因表达热图上表现为一个像素点，此时的分析单元为Bin1，即一个像素点只包含一个DNB的数据。将相邻N×N个DNB数据合并，在基因表达热图上以一个像素点的形式展示，此时分析单元为BinN。如Bin100表示一个分析单元包含100×100=10000个DNB区域的数据。Bin大小的选择会根据细胞大小、基因数量进行调整。不同Bin Size的基因捕获统计结果见表$ntable。取Bin200对测序饱和度进行统计，结果见图$nfigure。\n";
# if($step=~/2/) # by liucj
# {
# $arf_cn.="\@table\nnumber = $ntable\ntitle = \"不同Bin Size的基因捕获量统计结果\"\nfile = <url = IDBiotech_result/all_samples.table4_binstat.xls>\nformat = <field = 1; type = string; align =centre; desc = \"Chip\">\nformat = <field = 2; type = string; align =centre; desc = \"Bin Size\">\nformat = <field = 3; type = string; align =centre; desc = \"Mean Gene Types\">\nformat = <field = 4; type = string; align =centre; desc = \"Median Gene Types\">\nformat = <field = 5; type = string; align =centre; desc = \"Mean MIDs\">\nformat = <field = 6; type = string; align =centre; desc = \"Median MIDs\">\nfootnote = \"Bin Size：合并作为一个单元进行分析的DNB数量；\"\nfootnote = \"Mean Gene Types：所有Bin中捕获到基因类型的平均数；\"\nfootnote = \"Median Gene Types：所有Bin中捕获到基因类型的中位数；\"\nfootnote = \"Mean MIDs：所有Bin中表征基因表达量的MID平均数；\"\nfootnote = \"Median MIDs：所有Bin中表征基因表达量的MID中位数。\"\nview = -1 \n";
# } # liucj
# $arf_en.="\@paragraph\nIn STOmics, Bin is the basic unit for data statistics which represents a region with a fixed size. The expression quantity of DNBs within the region accumulates, and all regions do not coincide with each other. The BBin number represents a unilateral DNB number. Each DNB on the STOmics chip is a pixel point on the gene expression heatmap, and the analysis unit at this time is Bin1, which means one Bin contains data from only one DNB data. When adjacent N×N DNB data is combined and displayed as a single pixel on the gene expression heat map, the analysis unit now is BinN. For instance, Bin100 indicates an analysis unit that contains data of 100 x 100 = 10,000 DNBs. The selection of Bin size could can be adjusted according to cell size and gene number. Statistical results of gene captured with different Bin sizes are shown in Table $ntable. Bin150 was used to detect the sequencing saturation, and the results are shown in Figure $nfigure.
# For MID-based correction calculation and sequencing saturation description, please refer to supplementary supporting documents.\n";
# if($step=~/2/) # by liucj
# {
# $arf_en.="\@table\nnumber = $ntable\ntitle = \" Statistical of genes captured in different Bin sizes\"\nfile = <url = IDBiotech_result/all_samples.table4_binstat.xls>\nformat = <field = 1; type = string; align =centre; desc = \"Chip\">\nformat = <field = 2; type = string; align =centre; desc = \"Bin Size\">\nformat = <field = 3; type = string; align =centre; desc = \"Mean Gene Types\">\nformat = <field = 4; type = string; align =centre; desc = \"Median Gene Types\">\nformat = <field = 5; type = string; align =centre; desc = \"Mean MIDs\">\nformat = <field = 6; type = string; align =centre; desc = \"Median MIDs\">\nfootnote = \"Bin Size: Combine the number of DNB analyzed as a unit;\"\nfootnote = \"Mean Gene Types: Average number of genes captured in a Bin;\"\nfootnote = \"Median Gene Types: Median number of genes captured in a Bin;\"\nfootnote = \"Mean MIDs: Average MID values representing gene expression levels in a Bin;\"\nfootnote = \"Median MIDs: Median MID values representing gene expression levels in a Bin.\"\nview = -1\n";
# }
# $ntable++;
# $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"测序饱和度曲线（Bin200）\"\n";
# $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Sequencing saturation curve (Bin200)\"\n";
# foreach my $each(@samples){
#     $arf_cn.="file =  <url = IDBiotech_result/$each/01.Filter/plot_200x200_saturation.png; label = \"$each\">\n";
#     $arf_en.="file =  <url = IDBiotech_result/$each/01.Filter/plot_200x200_saturation.png; label = \"$each\">\n";
# }
# $arf_cn.="size = <width = 600>\ndesc=\"左图，横坐标为每个Bin中平均reads数，纵坐标为序列饱和度；中图，横坐标为每个Bin中reads数，纵坐标为检测到的基因数；右图，横坐标为每个Bin中reads数，纵坐标为其中的Unique reads数。\"\n\n";
# $arf_en.="size = <width = 600>\ndesc=\"Left, x-axis is the average number of reads per Bin, y-axis is the sequence saturation; Middle, x-axis is the number of reads in each Bin, y-axis is the number of genes detected; Right, x-axis is the number of reads in each Bin, y-axis is the number of unique reads detected.\"\n\n";
# $nfigure++;


# have to copy result 
# maybe need others 
# not use cp -rf 
foreach my $each(@samples){
    # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
    system ("mkdir -m 755 -p $IDBiotech_result/$each/01.Data_report") unless (-d "$IDBiotech_result/$each/01.Data_report");
    system("cp -r $indir/$each/01.Data_report/* $IDBiotech_result/$each/01.Data_report");
}


# Piepline_plot Result
# step 1
#===================================================================================================================================================================================
### 2.Normalize ###

foreach my $each(@samples){
    # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
    system ("mkdir -m 755 -p $IDBiotech_result/$each/02.Normalize") unless (-d "$IDBiotech_result/$each/02.Normalize");
    system("cp $indir/$each/02.Normalize/*.png $indir/$each/02.Normalize/*.pdf $IDBiotech_result/$each/02.Normalize");
}

$arf_cn.="\%result\n\@title\n数据标准化\n\@paragraph\n对单个样品的不同文库分别质控， 满足质控标准后合并用于后续分析。 通过可视化细胞的基因分布图， UMI分布图， 可以评估每个样品的细胞活性及基因表达况。线粒体RNA比例， RNA数量和表达量在一定程度上可以反映出细胞活性和质量。 一般来说， 线粒体RNA比例越低、 RNA数量越多、 RNA表达量越高的细胞， 其活性和质量越好。\n";

$arf_en.="\%result\n\@title\nData Normalization\n\@paragraph\nThe different libraries of a single sample were controlled separately and combined for subsequent analysis after meeting the quality control criteria. By visualizing the cell gene profile, UMI profile, the cell activity and gene expression status of each sample can be assessed. Mitochondrial RNA ratio, RNA quantity and expression can reflect cell activity and quality to some extent. In general, the lower the proportion of mitochondrial RNA, the higher the number of RNA, and the higher the expression of RNA, the better the activity and quality of cells.\n";

$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"mRNA和线粒体RNA相关性散点图\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Scatter plot of mRNA and mitochondrial RNA correlation\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/02.Normalize/sample_$each\_fig1\_scatterplot.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/02.Normalize/sample_$each\_fig1\_scatterplot.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 768>\ndesc=\"每个点表示一个细胞。 左图： X轴表示mRNA表达量， Y轴表示线粒体RNA比例； 右图： X轴mRNA表达量， Y轴表示mRNA数。 图中数字表示相关性系。\"\n\n";
$arf_en.="size = <width = 768>\ndesc=\"Each dot represents a cell. Left: X axis represents mRNA expression, Y axis represents the proportion of mitochondrial RNA; Right: mRNA expression on the X-axis and mRNA number on the Y-axis. The numbers in the figure represent the correlation system.\"\n\n";
$nfigure++;


$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"QC小提琴图\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"QC violin diagram\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/02.Normalize/sample_$each\_fig1\_vlnplot.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/02.Normalize/sample_$each\_fig1\_vlnplot.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 768>\ndesc=\"左图： mRNA数； 中图： mRNA表达量； 右图： 线粒体RNA比例。\"\n\n";
$arf_en.="size = <width = 768>\ndesc=\"Left: mRNA number; Middle figure: mRNA expression; Right: Mitochondrial RNA ratio.\"\n\n";
$nfigure++;


$arf_cn.="\n\@paragraph\n根据定量结果进行数据过滤， 过滤掉mRNA表达量过低或过高， 以及线粒体RNA比例过高的细胞， 详见信息分析流程-数据质控和过滤， 过滤后的数据集对细胞内所有基因的表达量进行均一化用于后续分析。\n";

$arf_en.="\n\@paragraph\nAccording to the quantitative results, the data was filtered out, and the cells with too low or too high mRNA expression and too high proportion of mitochondrial RNA were filtered out. For details, see the information analysis flow - Data Quality Control and Filtering. After filtering, the expression levels of all genes in the cells were homogenized for subsequent analysis.\n";



# Pipeline_plot Result 
# step 1
#===================================================================================================================================================================================
### 3. High VariableFeatures ###
my $subtitle2=1;
foreach my $each(@samples){
    # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
    system ("mkdir -m 755 -p $IDBiotech_result/$each/03.HvgPCA") unless (-d "$IDBiotech_result/$each/03.HvgPCA");
    system("cp $indir/$each/03.HvgPCA/*.png $indir/$each/03.HvgPCA/*.pdf $IDBiotech_result/$each/03.HvgPCA");
}

### 3.1 HVG ###
$arf_cn.="\%result\n\@title\n高变基因选择和PCA降维\n\@paragraph\n
\@subtitle\nnumber = $subtitle2\n 高变特征筛选 \n\@paragraph\n 基于每个样品中所有基因平均值和分散度（ 均值和方差） ， 使用R包-Seurat\\reference{$nreference}筛选出每个样品中呈现高变异度的基因， 用于下游的PCA分析。 默认挑选变异程度最高的2000个基因。 详见信息分析流程-高变特征筛选。\n";

$arf_en.="\%result\n\@title\nHigh variable gene selection and PCA dimensionality reduction\n\@paragraph\n
\@subtitle\nnumber = $subtitle2\n Highly variable feature screening \n\@paragraph\n Based on the mean and dispersion (mean and variance) of all genes in each sample, R-package -Seurat\\reference{$nreference} was used to screen out genes with high variability in each sample for downstream PCA analysis. The 2,000 genes with the highest degree of variation are selected by default. See Information Analysis Flow - High Variable Feature Screening for details.\n";

# add figures 
$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"高变基因筛选图\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"High variant gene screening plot\"\n";
# have to change this in plot code 
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_var.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_var.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 860>\ndesc=\"X轴表示平均表达量,Y轴表示标准化方差,右图在左图基础上标注了表达量变异程度top 10的marker基因。\"\n\n";
$arf_en.="size = <width = 860>\ndesc=\"The X-axis represents the average expression level, and the Y-axis represents the standardized variance. On the basis of the left figure, marker genes with the top 10 expression level variation were marked in the right figure.\"\n\n";

$nfigure++;
$subtitle2++;



### 3.2 PCA ###
my $tmp_fig1=$nfigure+1;

$arf_cn.="\n\@subtitle\nnumber = $subtitle2\n 主成分分析 \n\@paragraph\n维度热图展示了主成分（ PC） 的变异最大的基因和及其表达量在细胞数据中的异质性， 有助于选择合适的维度进行下游分析。 同时也可以采用折线图 (elbow plot) 决定使用多少个PC来聚类， 以便捕捉到数据中大部分的变化。 图$nfigure和图$tmp_fig1用于展示top15PC的降维结果， 可以看到随着PC成分的增加， 特征越来越不明显， 有助于下游选择合适的维度。\n";

$arf_en.="\n\@subtitle\nnumber = $subtitle2\n Principl component analysis \n\@paragraph\n Dimensional heat maps show the heterogeneity of principal component (PC) genes with the greatest variation and their expression levels in cell data, helping to select appropriate dimensions for downstream analysis. You can also use the elbow plot to determine how many PCS are used to cluster in order to capture most of the changes in the data. Figure $nfigure and Figure $tmp_fig1 are used to show the dimension reduction results of top15PC. It can be seen that with the increase of PC components, features become less and less obvious, which is helpful for downstream selection of appropriate dimensions.\n";

# add figures 
$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Top15 PC的降维热图\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Dimension reduction heatmap for Top15 PCS\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_pca.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_pca.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 1200>\ndesc=\"每列表示一个细胞， 每行表示一个基因； 黄色表示高表达， 紫色表示低表达。\"\n\n";
$arf_en.="size = <width = 1200>\ndesc=\"Each column represents a cell and each row represents a gene; Yellow indicates high expression and purple indicates low expression.\"\n\n";
$nfigure++;

# add figures 
$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Top15 PC的elbow plot图\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Elbow plot for Top15 PCS\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_elbowplot.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/03.HvgPCA/sample_$each\_fig3\_elbowplot.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 768>\ndesc=\"X轴为PC序号， Y轴为标准差。\"\n\n";
$arf_en.="size = <width = 768>\ndesc=\"The X-axis is the PC serial number and the Y-axis is the standard deviation.\"\n\n";
$nfigure++;

$subtitle2++;





# Decontamination Result
# step 2
#===================================================================================================================================================================================
### 4. Decontamination ###

foreach my $each(@samples){
    # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
    system ("mkdir -m 755 -p $IDBiotech_result/$each/04.Decontamination") unless (-d "$IDBiotech_result/$each/04.Decontamination");
    system("cp $indir/$each/04.Decontamination/*.png $indir/$each/04.Decontamination/*.pdf $IDBiotech_result/$each/04.Decontamination");
}

$arf_cn.="\%result\n\@title\n数据清洗\n\@paragraph\n对单个样品的不同文库分别数据清洗和过滤， 满足质控标准后合并用于后续分析。 通过计算液滴中可能存在的双细胞（核）比例以及可能存在的外来RNA污染，利用假设检验推断出在一定概率下最有可能受到污染或者是双胞（核）的细胞。计算结果通过数据的降维聚类图展示，两种过滤方法均淘汰的细胞会被剔除，不纳入后续的分析中。\n";

$arf_en.="\%result\n\@title\nData Clean\n\@paragraph\nDifferent libraries of a single sample were cleaned and filtered separately, and then combined for subsequent analysis after meeting the quality control standards. By calculating the possible proportion of double cells (nuclear) in the droplet and the possible foreign RNA contamination, the cells most likely to be contaminated or double cells (nuclear) were inferred by hypothesis testing under a certain probability. The results of the calculation are presented by the dimensionality reduction cluster plot of the data, and the cells eliminated by both filtering methods are eliminated and not included in the subsequent analysis.\n";

$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"DoubletFinder 识别的双胞（核）以及非双胞。\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Doublets (nuclear) and Singlets cells identified by DoubletFinder.\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/04.Decontamination/sample_${each}_doublets_dimplot.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/04.Decontamination/sample_${each}_doublets_dimplot.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 768>\ndesc=\"每个点表示一个细胞。不同颜色表示细胞类型，红色表示细胞为双胞（核），青色表示细胞为非双胞。\"\n\n";
$arf_en.="size = <width = 768>\ndesc=\"Each dot represents a cell. Different colors indicate cell types; red indicates that the cell is Doublets (nuclear) and cyan indicates that the cell is Singlets. \"\n\n";
$nfigure++;


$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"DecontX 识别污染细胞。\"\n";
$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"DecontX identifies contaminated cells.\"\n";
# have to change this
foreach my $each(@samples){
    $arf_cn.="file =  <url = IDBiotech_result/$each/04.Decontamination/sample_${each}_decontx_class.png; label = \"$each\">\n";
    $arf_en.="file =  <url = IDBiotech_result/$each/04.Decontamination/sample_${each}_decontx_class.png; label = \"$each\">\n";
}
$arf_cn.="size = <width = 768>\ndesc=\"每个点表示一个细胞。不同颜色表示细胞类型，红色表示细胞被污染可能性较高，青色表示细胞被污染的可能性较低。\"\n\n";
$arf_en.="size = <width = 768>\ndesc=\"Each dot represents a cell. Different colors indicate cell types, with red indicating a higher probability of cell contamination and cyan indicating a lower probability of cell contamination.\"\n\n";
$nfigure++;


$arf_cn.="\n\@paragraph\n根据定量结果进行数据过滤， 过滤掉可能是双胞（核）或存在污染的细胞， 过滤后的数据集对细胞内所有基因的表达量进行均一化用于后续分析。\n";

$arf_en.="\n\@paragraph\nAccording to the quantitative results, the data were filtered out, and the cells that might be double (nuclear) or with contamination were filtered out. The filtered data set was used to homogenize the expression levels of all genes in the cells for subsequent analysis.\n";





# SingleSample Result including Cell clustering
# step 3
# dependent on step2
#===================================================================================================================================================================================
### 4. Single sample analysis ###

if($step=~/3/){

    my $subtitle3=1;
    foreach my $each(@samples){
        # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
        system ("mkdir -m 755 -p $IDBiotech_result/$each/04.sSample") unless (-d "$IDBiotech_result/$each/04.sSample");
        system("cp $indir/$each/04.sSample/*.png $indir/$each/04.sSample/*.pdf $IDBiotech_result/$each/04.sSample");
    }

    ### 4.1 cell cluster ###
    $arf_cn.="\%result\n\@title\n单样本分析\n\@paragraph\n\@subtitle\nnumber = $subtitle3\n 细胞聚类 \n\@paragraph\n首先使用PCA对基因的表达矩阵进行降维处理， 之后使用UMAP进行细胞聚类， 生成细胞聚类结果见图6。 该图中每个点代表一个细胞， 空间距离近的点表示这些细胞的基因表达模式比较接近； 颜色根据graph-based聚类算法得到的分类决定， 算法认为同一个cluster内的细胞， 基因表达模式最接近。\n";

    $arf_en.="\%result\n\@title\nSingle sample analysis\n\@paragraph\n\@subtitle\nnumber = $subtitle3\n Cell Clustering \n\@paragraph\n Firstly, PCA was used for dimensionality reduction of gene expression matrix, and then UMAP was used for cell clustering. The cell clustering results were shown in Figure 6. In this figure, each point represents a cell, and the closest points in space indicate that the gene expression patterns of these cells are more similar. The colors are determined by a graph-based clustering algorithm that identifies cells within a cluster as having the most similar gene expression patterns.\n";

    # add figures 
    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"细胞聚类结果\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \" Cell clustering result\"\n";
    # have to change this in plot code 
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_fig4\_cluster.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_fig4\_cluster.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 768>\ndesc=\"X轴表示的是UMAP第一成分， Y轴表示的是UMAP第二成分。 数字和颜色代表cluster编号。\"\n\n";
    $arf_en.="size = <width = 768>\ndesc=\"The X-axis represents the first component of UMAP, and the Y-axis represents the second component of UMAP. The number and color represent the cluster number.\"\n\n";
    $nfigure++;

    $subtitle3++;


    ### 4.2 Marker gene identification ###

    $arf_cn.="\n\@subtitle\nnumber = $subtitle3\n Marker基因鉴定 \n\@paragraph\n使用R包-Seurat分别计算每一类细胞与其他类群的差异表达基因(marker 基因)， 筛选矫正后p-value<0.05且log2FC(log2 fold change:用于评估平均表达量差异倍数)top10 marker基因用于后续结果可视化。表4用于展示结果的前5行， 完整表格详见交付目录IDBiotech_result/4.single_sample/*/2.marker_find/*top10_GeneDiffExp.xls。\n";

    $arf_en.="\n\@subtitle\nnumber = $subtitle3\n Marker gene identification \n\@paragraph\n Seurat was used to calculate the differentially expressed genes (marker genes) between each type of cell and other groups. After screening and correction, top10 marker genes with p-value<0.05 and log2FC(log2 fold change: used to evaluate the average expression difference multiple) were used for visualization of subsequent results. Table 4 shows the first five rows of results. The complete table is in the delivery directory IDBiotech_result/ 4.SINGLE_SAMPLE /*/2.marker_find/*top10_GeneDiffExp.xls.\n";

    # make a table 
    foreach my $each(@samples){
        $arf_cn.="\@table\nnumber = $ntable\ntitle = \"$each细胞类群Marker基因（Top3）\"\nfile = <url = IDBiotech_result/$each/04.sSample/sample_$each\_top3_Markers.xls>\nformat = <field = 1; type = string; align =centre; align =centre; desc = \"P-value\">\nformat = <field = 2; type = string; align =centre; desc = \"Average log2FC\">\nformat = <field = 3; type = string; align =centre; desc = \"pct.1\">\nformat = <field = 4; type = string; align =centre; desc = \"pct.2\">\nformat = <field = 5; type = string; align =centre; desc = \"Adjusted P-value\">\nformat = <field = 6; type = string; align =centre; desc = \"Cluster\">\nformat = <field = 7; type = string; align =centre; desc = \"Gene\">\nfootnote = \"pct.1：在当前细胞类群（Cluster）中检测到的Marker细胞的百分比；\"\nfootnote = \" pct.2：在其余细胞类群（Cluster）中检测到的Marker细胞的百分比。\"\nfootnote = \" avg_logFC：记录两组之间平均表达式的差异倍数,正值表示该特征在当前cluster中表达得更高。\"\nfootnote = \" p_val_adj：调整后的p值， 越小越显著。\"\nfootnote = \" cluster：细胞类群。\"\nview = -1\n\n";
        
        $arf_en.="\@table\nnumber = $ntable\ntitle = \"${each}Marker genes of cell clustering(Top3)\"\nfile = <url = IDBiotech_result/$each/04.sSample/sample_$each\_top3_Markers.xls>\nformat = <field = 1; type = string; align =centre; align =centre; desc = \"P-value\">\nformat = <field = 2; type = string; align =centre; desc = \"Average log2FC\">\nformat = <field = 3; type = string; align =centre; desc = \"pct.1\">\nformat = <field = 4; type = string; align =centre; desc = \"pct.2\">\nformat = <field = 5; type = string; align =centre; desc = \"Adjusted P-value\">\nformat = <field = 6; type = string; align =centre; desc = \"Cluster\">\nformat = <field = 7; type = string; align =centre; desc = \"Gene\">\nfootnote = \"pct.1: Percentage of Marker cells in the current cell cluster;\"\nfootnote = \"pct.2: Percentage of Marker cells in other remaining cell clusters.\"\nfootnote = \"avg_logFC: A multiple of the difference in the average expression between the two groups is recorded, with a positive value indicating that the feature is expressed more highly in the current cluster.\"\nfootnote = \"p_val_adj: The adjusted P-value, the smaller of adjusted Pvalue, the more significant it is.\"\nfootnote = \"cluster: cell clusters.\"\nview = -1\n\n";
        $ntable++;
        last; # just for one times
    }
    $subtitle3++;


    ### 4.3 Marker gene analysis ###
    foreach my $each(@samples){
        system ("cp $indir/$each/04.sSample/*.png $indir/$each/04.sSample/*.pdf $indir/$each/04.sSample/*.xls $indir/$each/04.sSample/*.RDS $IDBiotech_result/$each/04.sSample");
    }

    my $tmp_fig11=$nfigure+1;
    my $tmp_fig22=$nfigure+2;

    $arf_cn.="\n\@subtitle\nnumber = $subtitle3\n Marker基因分析 \n\@paragraph\n对得到的Marker基因， 统计其在不同细胞类群中的表达情况， 使用聚类热图、 气泡图和小提琴图等方式进行可视化展示， 每个细胞类群中Top3基因的结果分别见图$nfigure、 图$tmp_fig11和图$tmp_fig22。\n";

    $arf_en.="\n\@subtitle\nnumber = $subtitle3\n Marker gene identification \n\@paragraph\n The obtained Marker genes were statistically expressed in different cell groups, and visualized by means of clustering heat map, bubble map and violin map. The results of Top3 genes in each cell group were shown in figure$nfigure, figure$tmp_fig11 and figure$tmp_fig22, respectively.\n";


    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Marker基因聚类热图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Heatmap of Marker gene clustering\"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_heatmapClusters.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_heatmapClusters.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 1000>\ndesc=\"横坐标为不同的细胞类群；纵坐标为Marker基因；黄色代表高表达，紫色代表低表达。\"\n\n";
    $arf_en.="size = <width = 1000>\ndesc=\"The abscissa represents different cell groups; The ordinate is Marker gene; Yellow represents high expression and purple represents low expression.\"\n\n";
    $nfigure++;

    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Marker基因气泡热图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Bubble heatmap of Marker gene \"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_dotplotClusters.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_dotplotClusters.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 1200>\ndesc=\"横坐标为Marker基因，纵坐标为不同的细胞类群；颜色从浅到深，颜色越深表示基因平均表达量越高；圆形越大表示表达该基因的细胞数目越多。\"\n\n";
    $arf_en.="size = <width = 1200>\ndesc=\"The abscissa is Marker gene and the ordinate is different cell group. The color ranges from light to dark, darker color represent higher expression level. Larger bubble indicates a higher percentage of cells expressing the gene in the cell group.\"\n\n";
    $nfigure++;

    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Marker基因小提琴图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Violin diagram of Marker gene \"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_vlnplotClusters.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/04.sSample/sample_$each\_vlnplotClusters.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 1200>\ndesc=\"纵坐标为不同细胞类群，横坐标为Marker 基因表达量，数字越高表示基因的表达量越高。\"\n\n";
    $arf_en.="size = <width = 1200>\ndesc=\"The ordinate is different cell groups, and the abscissa is specific marker genes’ expression levels. \"\n\n";
    $nfigure++;

}

# KEGG GO Result 
# step 4
#===================================================================================================================================================================================
### 5. GO and KEGG annlysis ###
# 2023-11-07

if($step=~/4/){

    my $subtitle5=1;
    # copy png to IDBiotech file result
    foreach my $each(@samples){
        # system("mkdir -p $IDBiotech_result/$each/04.Pseudotime");
        system ("mkdir -m 755 -p $IDBiotech_result/$each/05.GOKEGG") unless (-d "$IDBiotech_result/$each/05.GOKEGG");
        system("cp $indir/$each/05.GOKEGG/*.png $indir/$each/05.GOKEGG/*.pdf $IDBiotech_result/$each/05.GOKEGG");
    }
    my $tmp_fig5=$nfigure+1;

    $arf_cn.="\%result\n\@title\n功能富集分析\n\@paragraph\n在每一种细胞类群的所有Marker基因中筛选显著的差异表达基因（ adjust P-value < 0.05 && Log2FC > 0.5），使用clusterProfiler软件分别对每一个细胞类群的差异基因进行GO（Gene Ontology）和KEGG（Kyoto Encyclopedia of Genes and Genomes）功能富集分析\\reference{$nreference}。GO和KEGG富集分析结果图$nfigure和$tmp_fig5。\n";
    $arf_en.="\%result\n\@title\nFunctional Enrichment Analysis\n\@paragraph\nSignificat differently expressed Genes(DEGs, adjust P-value < 0.05 && Log2FC > 0.5) were screened from all Marker genes in each cell cluster. ClusterProfiler was used to conduct functional enrichment analysis of GO (Gene Ontology) and KEGG (Kyoto Encyclopedia of Genes and Genomes) categories\\reference{$nreference}. Enrichment results are shown from Figure $nfigure to $tmp_fig5.\n";

    ### 5.1 GO analysis ###
    $arf_cn.="\n\@subtitle\nnumber = $subtitle5\nGO富集分析\n\@paragraph\n 对差异基因使用基因本体论数据库（GO）进行富集分析。\n";
    $arf_en.="\n\@subtitle\nnumber = $subtitle5\n GO enrichment analysis \n\@paragraph\n The differential genes were enriched using the gene ontology database (GO).\n";


    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"GO富集分析结果图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Barplot of GO enrichment\"\n";
    foreach my $each(@samples){
        my @gofiles=`ls $IDBiotech_result/$each/05.GOKEGG/Cluster*_GO_Barplot.png | awk -F"Cluster" '{print \$2}'| awk -F"_" '{print \$1}'|sort -k1n `;
        chomp @gofiles;
        foreach my $gg(@gofiles){
            
            $arf_cn.="file =  <url = IDBiotech_result/$each/05.GOKEGG/Cluster${gg}_GO_Barplot.png; label = \"${each}_${gg} cluster\">\n";
            $arf_en.="file =  <url = IDBiotech_result/$each/05.GOKEGG/Cluster${gg}_GO_Barplot.png; label = \"${each}_${gg} cluster\">\n";
        } 
    }
    $arf_cn.="size = <width = 1400>\ndesc=\"横轴为富集基因数目，纵轴为显著富集到的GO term，颜色对应不同的GO数据库子集，分子功能（Molecular Function，MF，细胞组分（Cellular Component ，CC）），生物过程（Biological Process ，BP）。\"\n";
    $arf_en.="size = <width = 1400>\ndesc=\"X-axis, number of enriched genes; y-axis, the significant enriched GO term; The dot color corresponds to different GO database, Molecular Function(MF),Cellular Component(CC), and Biological Process(BP).\"\n";
    $nfigure++;
    $subtitle5++;


    # $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"GO富集分析网络连接图\"\n";
    # $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Network connection diagram of GO enrichment analysis\"\n";
    # foreach my $each(@samples){
    #     my @gofiles=`ls $IDBiotech_result/$each/05.GOKEGG/cluster*.GO.emapplot.png | sort -k1.8n | awk -F"cluster" '{print \$2}'| awk -F"." '{print \$1}'`;
    #     chomp @gofiles;
    #     foreach my $gg(@gofiles){
    #         $arf_cn.="file =  <url = IDBiotech_result/$each/05.GOKEGG/cluster$gg.degs.list.GO.emapplot.png; label = \"${each}_${gg} cluster\">\n";
    #         $arf_en.="file =  <url = IDBiotech_result/$each/05.GOKEGG/cluster$gg.degs.list.GO.emapplot.png; label = \"${each}_${gg} cluster\">\n";
    #     } 
    # }
    # $arf_cn.="size = <width = 600>\ndesc=\"圆点为富集到的GO term，圆点大小表示基因数，圆点颜色表示P-value的值，越红表示富集效果越显著；连接线的粗细表示两个GO terms之间共有的基因数。\"\n";
    # $arf_en.="size = <width = 600>\ndesc=\"The dot is the enriched GO term, the dot size represents the number of genes, the dot color corresponds to the P-value, and the redder the color, the more significant the enrichment. The thickness of the connection line indicates the number of common genes between two GO terms.\"\n";
    # $nfigure++;


    ### 5.2 KEGG analysis ###
    $arf_cn.="\n\@subtitle\nnumber = $subtitle5\nKEGG富集分析\n\@paragraph\n 对差异基因使用KEGG通路数据库进行富集分析。\n";
    $arf_en.="\n\@subtitle\nnumber = $subtitle5\n KEGG enrichment analysis \n\@paragraph\n The differential genes were enriched using the KEGG pathway database.\n";


    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"KEGG富集分析结果图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Barplot of KEGG enrichment analysis\"\n";
    foreach my $each(@samples){
        my @keggfiles=`ls $IDBiotech_result/$each/05.GOKEGG/Cluster*_KEGG_Barplot.png |  awk -F"Cluster" '{print \$2}'| awk -F"_" '{print \$1}'|sort -k1n `;
        chomp @keggfiles;
        foreach my $kk(@keggfiles){
            $arf_cn.="file =  <url = IDBiotech_result/$each/05.GOKEGG/Cluster${kk}_KEGG_Barplot.png; label = \"${each}_${kk} cluster\">\n";
            $arf_en.="file =  <url = IDBiotech_result/$each/05.GOKEGG/Cluster${kk}_KEGG_Barplot.png; label = \"${each}_${kk} cluster\">\n";
        }
    }
    $arf_cn.="size = <width = 1200>\ndesc=\"横轴为富集基因数目，纵轴为富集到的KEGG Pathway，颜色对应P-value的值，越深表示富集效果越显著。\"\n";
    $arf_en.="size = <width = 1200>\ndesc=\"X-axis, number of enriched genes; y-axis, enriched KEGG Pathway; The dot color corresponds to log10(P-value), and the darker the color, the more significant the enrichment.\"\n";
    $nfigure++;
    $subtitle5++;
    # $nreference=$tmp_nref2;

    # $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"KEGG富集分析网络连接图\"\n";
    # $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Network connection diagram of KEGG enrichment analysis\"\n";
    # foreach my $each(@samples){
    #     my @keggfiles=`ls $IDBiotech_result/$each/05.GOKEGG/cluster*.KEGG.emapplot.png | sort -k1.8n |awk -F"cluster" '{print \$2}'|awk -F"." '{print \$1}'`;
    #     chomp @keggfiles;
    #     foreach my $kk(@keggfiles){
    #         $arf_cn.="file =  <url = IDBiotech_result/$each/05.GOKEGG/cluster$kk.degs.list.KEGG.emapplot.png; label = \"${each}_${kk} cluster\">\n";
    #         $arf_en.="file =  <url = IDBiotech_result/$each/05.GOKEGG/cluster$kk.degs.list.KEGG.emapplot.png; label = \"${each}_${kk} cluster\">\n";
    #     }
    # }
    # $arf_cn.="size = <width = 600>\ndesc=\"圆点为富集到的KEGG Pathway，圆点大小表示基因数，圆点颜色表示P-value的值，越红表示富集效果越显著；连接线的粗细表示两个GO terms之间共有的基因数。\"\n";
    # $arf_en.="size = <width = 600>\ndesc=\"The dot is the enriched KEGG Pathway, the dot size represents the number of genes, the dot color corresponds to the P-value, and the redder the color, the more significant the enrichment. The thickness of the connection line indicates the number of common genes between two GO terms.\"\n";
    # $nfigure++;

}



# SingleR Result 
# step 5
#===================================================================================================================================================================================
### 6. SingleR analysis ###

if($step=~/5/){

    my $tmp_nfig6=$nfigure+1;

    foreach my $each(@samples){
    #    system("mkdir -p $IDBiotech_result/$each/06.SingleR/SciBet");
        # system("mkdir -p $IDBiotech_result/$each/06.SingleR/SingleR");
        system ("mkdir -m 755 -p $IDBiotech_result/$each/06.SingleR") unless (-d "$IDBiotech_result/$each/06.SingleR");
        system("cp $indir/$each/06.SingleR/*.png $indir/$each/06.SingleR/*.pdf $IDBiotech_result/$each/06.SingleR");
    #    system("cp $indir/$each/06.SingleR/SciBet/*.png $indir/$each/06.SingleR/SciBet/*.pdf $IDBiotech_result/$each/06.SingleR/SciBet");
    }


    $arf_cn.="\%result\n\@title\n细胞亚群注释\n\@paragraph\n通过聚类分析得到不同细胞类群后，除了使用每个cluster的Marker基因信息对细胞类群进行初步的注释和分析之外，还可通过其他软件将细胞类群与参考数据库进行比较，以得到分群后不同细胞的细胞类群注释信息。\nSingleR细胞注释\nSingleR\\reference{$nreference}可以将细胞聚类结果中的每个cluster与参考数据库进行比较，根据该cluster与参考数据库中已知细胞类群基因表达谱的相似性对cluster进行打分，最终得到一个打分矩阵。通过打分矩阵结果即可将细胞聚类结果注释为不同的细胞类群。细胞类群的打分矩阵结果见图$nfigure，细胞类群注释结果见图$tmp_nfig6。\n";
    $arf_en.="\%result\n\@title\nAnnotation of Cell Clusters\n\@paragraph\nAfter dividing cells into different groups through cluster analysis, cell types are further identified by using marker gene information in public databases.\nSingleR Cell Annotation\nSingleR\\reference{$nreference}can recognize the existing cell clustering results based on Seurat, compare each cluster with a reference data set, and score the cluster according to the similarity of gene expression between cluster and known cell groups in the reference data set to obtain a scoring matrix. Cells/Bins can be annotated into different groups by scoring matrix results. The visualization results of the scoring matrix of cell clustering results are shown in Figure $nfigure, and the annotation results of cell groups are shown in Figure $tmp_nfig6.\n";

    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SingleR细胞类群注释打分热图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Scoring heatmap of cell cluster annotation by SingleR\"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/06.SingleR/${each}_Heatmap_singleR.png; label = \"${each}\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/06.SingleR/${each}_Heatmap_singleR.png; label = \"${each}\">\n";
    }
    $arf_cn.="size = <width = 768>\ndesc=\"横坐标为细胞聚类结果的cluster，纵坐标为参考数据集中包含的细胞类型，每一格颜色越接近黄色表示打分越高；最上方Labels表示SingleR给出的细胞注释结果\"\n";
    $arf_en.="size = <width = 768>\ndesc=\"x-axis, the cell clusters; y-axis, cell types contained in the reference dataset; the color ranges from blue to yellow, and the more closer to yellow, the higher scores; top lables represent the annotation result by SingleR.\"\n";
    $nfigure++;
    $nreference++;

    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SingleR细胞类群注释结果图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Annotation results of cell clusters by SingleR\"\n";
    foreach my $each(@samples){
        $arf_cn.="file = <url = IDBiotech_result/$each/06.SingleR/${each}_DimPlot_singleR.png; label = \"${each}\">\n";
        $arf_en.="file = <url = IDBiotech_result/$each/06.SingleR/${each}_DimPlot_singleR.png; label = \"${each}\">\n";
    }
    $arf_cn.="size = <width = 900; height = 350>\ndesc=\"UMAP细胞聚类结果图。每一种颜色代表SingleR注释得到的一种细胞类群。 \"\n";
    $arf_en.="size = <width = 900; height = 350>\ndesc=\"Cluster results of UMAP. Each color represents a cell cluster annotaed by SingleR.\"\n";
    $nfigure++;

}









# Monocle Result 
# step 6
#===================================================================================================================================================================================
### 7. Monocle analysis ###
# ### Pseudotime ###
if($step=~/6/){
    foreach my $each(@samples){
        # system("mkdir -p $IDBiotech_result/$each/07.Monocle");
        system ("mkdir -m 755 -p $IDBiotech_result/$each/07.Monocle") unless (-d "$IDBiotech_result/$each/07.Monocle");
        system("cp $indir/$each/07.Monocle/*.png $IDBiotech_result/$each/07.Monocle");
    }

    # description
    $arf_cn.="\%result\n\@title\n拟时序分析\n\@paragraph\n拟时序分析（pseudotime analysis）也称为细胞轨迹分析（trajectory inference），是指根据不同细胞类群之间其基因差异表达的情况，获得细胞谱系的发育结果，构建细胞随着一个虚拟时间顺序的变化轨迹，以此重现细胞随时间变化而变化的过程。
        使用Monocle3\\reference{$nreference}软件进行拟时序分析，基于Seurat对象提取的矩阵进一步降维聚类，并判断降维后的聚类结果之间的表达量关联以确定是否属于同一发育轨迹。根据软件推测的发育轨迹进行细胞类群的可视化，结果见图$nfigure。\n";
    $arf_en.="\%result\n\@title\nPseudotime Analysis\n\@paragraph\nPseudotime analysis, also known as trajectory inference, refers to obtaining cell lineage information according to the differentially expressed genes among different cell groups and constructing a change trajectory of cells in a virtual timeline. Based on these results, a cell change timeline can be recreated.
        Monocle3\\reference{$nreference} was used for Pseudo-time analysis. Based on the result of dimensionality reduction and clustering, we further estimated whether the clustering results belonged to the same developmental trajectory. The cell groups were visualized according to the developmental trajectories predicted by the software, and the results are shown in Figure $nfigure.\n";
    
    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"细胞发育轨迹图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Cell development trajectory diagram\"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/07.Monocle/sample_${each}_track.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/07.Monocle/sample_${each}_track.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 768>\ndesc=\"图中黑色线条表示推测的细胞发育轨迹\"\n";
    $arf_en.="size = <width = 768>\ndesc=\"The black lines in the figure show the presumed trajectory of cell development.\"\n";
    $nfigure++;
    $nreference++;

    $arf_cn.="\@paragraph\n根据细胞发育轨迹结果中的节点信息，结合不同细胞类群中基因表达量的变化，Monocle3可以通过机器学习算法计算处于最早发育阶段的细胞，实现拟时序分析，结果见图$nfigure。\n";
    $arf_en.="\@paragraph\nAccording to the results of cell development trajectory, combined with the changes of gene expression levels in different cell groups, Monocle3 could identify the cells at the earliest developmental stage using a machine learning algorithm and create a pseudo-time analysis, as shown in Figure $nfigure.\n";
    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"拟时序分析结果图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Diagram of pseudo time series analysis results\"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/07.Monocle/sample_${each}_pseudotime.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/07.Monocle/sample_${each}_pseudotime.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 768>\ndesc=\"图中黑色线条表示推测的细胞发育轨迹，颜色从紫色到黄色，颜色越接近黄色表示细胞发育时间越晚\"\n";
    $arf_en.="size = <width = 768>\ndesc=\"The black lines represent the presumed developmental trajectory of the cells, ranging in color from purple to yellow, and the color closer to yellow, the cells develop the later.\"\n";
    $nfigure++;

    $arf_cn.="\@paragraph\n在不同的细胞类群聚类结果中，选取Monocle3计算得到的Top5 Marker基因，按照已获得的拟时序结果进行基因表达量的拟时序作图，结果见图$nfigure。\n";
    $arf_en.="\@paragraph\nIn the clustering results of different cell classes, the top 5 marker genes calculated by Monocle3 were selected, and the gene expression levels were visualized according to the obtained pseudo-time results, as shown in Figure $nfigure.\n";
    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"Marker基因动态表达结果图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Pseudo expression result of Marker gene\"\n";
    foreach my $each(@samples){
        $arf_cn.="file =  <url = IDBiotech_result/$each/07.Monocle/${each}_Cluster_1_monocle.png; label = \"$each\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/07.Monocle/${each}_Cluster_1_monocle.png; label = \"$each\">\n";
    }
    $arf_cn.="size = <width = 768>\ndesc=\"横坐标表示拟时序结果；纵坐标表示基因表达量，颜色从紫色到黄色，颜色越接近黄色表示细胞发育时间越晚；黑色线条表示基因表达趋势。\"\n";
    $arf_en.="size = <width = 768>\ndesc=\"x-axis, the result of Pseudotime; y-axis, gene expression, and the color ranges from purple to yellow. the color closer to yellow, the cell development time is the later. The black line shows trends in gene expression.\"\n";
    $nfigure++;
}



# CellChat Result 
# step 7
#===================================================================================================================================================================================
### 8. CellChat analysis ###

### Interaction ###
if($step=~/7/){
    foreach my $each(@samples){
        # system("mkdir -p $IDBiotech_result/$each/08.CellChat");
        system ("mkdir -m 755 -p $IDBiotech_result/$each/08.CellChat") unless (-d "$IDBiotech_result/$each/08.CellChat");
        system("cp $indir/$each/08.CellChat/*.png $indir/$each/08.CellChat/*.pdf $IDBiotech_result/$each/08.CellChat");
        # system("cp $indir/$each/08.CellChat/cellchat*.png $indir/$each/08.CellChat/cellchat*.pdf $IDBiotech_result/$each/08.CellChat");
    }
    my $tmp_nfig7=$nfigure+1;
#    $arf_cn.="\n\@subtitle\nnumber = $subtitle\n细胞类群互作分析\n\@paragraph\nCellPhoneDB\\reference{10}是一个公开的受体-配体相互作用的数据库，整合了现有的细胞通讯数据集和手动校正的信息，其数据来源于UniProt，Ensembl，PDB，IMEx联盟，IUPHAR等。本项目使用CellPhoneDB来鉴定时空数据中的配体/受体关系和细胞间的通讯分子，研究不同细胞类型之间的相互交流及通讯网络。所有细胞类群间的通讯网络见图$nfigure，每个类群与其他类群间的通讯网络见图$tmp_nfig。\n";
#    $nreference++
    $arf_cn.="\%result\n\@title\n细胞类群互作分析\n\@paragraph\nCellChat\\reference{$nreference}是一个能够从单细胞数据中定量推断和分析细胞间通信网络的工具，利用网络分析和模式识别方法预测细胞的主要信号输入和输出，以及这些细胞和信号如何协调功能。CellChatDB数据库整合了来自KEGG和最近研究中的信号分析信息，该数据库囊括了已知的配体-受体复合物组成，包括配体-受体多聚体复合物以及几类辅酶因子。本项目使用CellChat来鉴定时空数据中的配体/受体关系和细胞间的通讯分子，研究不同细胞类型之间的相互交流及通讯网络。所有细胞类群间的通讯网络见图$nfigure，每个类群与其他类群间的通讯网络见图$tmp_nfig7。\n";
    $arf_en.="\%result\n\@title\nInteraction of Cell Clusters\n\@paragraph\nCellChat\\reference{$nreference} is a tool capable of quantitatively inferring and analyzing cell-to-cell communication networks from single-cell data, using network analysis and pattern recognition methods to predict the main signal inputs and outputs of cells and how these cells and signals coordinate their functions. The CellChatDB database incorporates signal analysis information from KEGG and recent studies. The database includes known ligand-receptor complex compositions, including ligand-receptor polymeric complexes and several coenzyme factors. In this project, CellChat was used to identify ligand/receptor relationships and intercellular communication molecules in spatio-temporal data, and to study the interaction and communication networks between different cell types.The communication network among all cell clusters is shown in Fig$nfigure, and the communication network between each cluster and other clusters is shown in Fig$tmp_nfig7.\n";
    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"所有细胞类群间的细胞通讯网络图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Communication network diagram between all cell clusters\"\n";
    foreach my $each(@samples){
        # $arf_cn.="file =  <url = IDBiotech_result/$each/08.CellChat/network.png; label = \"${each}\">\n";
        $arf_cn.="file =  <url = IDBiotech_result/$each/08.CellChat/sample_${each}_netall.png; label = \"${each}\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/08.CellChat/sample_${each}_netall.png; label = \"${each}\">\n";
    }
    $arf_cn.="size = <width = 800>\ndesc=\"连线越粗表示两个cluster之间的互作越强。\"\n";
    $arf_en.="size = <width = 800>\ndesc=\"The thicker the connection line, the stronger the interaction between two clusters\"\n";
    $nfigure++;

    $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"每个细胞类群与其他类群间的细胞通讯网络图\"\n";
    $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Communication network diagram between each cell cluster and others\"\n";
    foreach my $each(@samples){
        # $arf_cn.="file =  <url = IDBiotech_result/$each/08.CellChat/seperate.png; label = \"${each}\">\n";
        $arf_cn.="file =  <url = IDBiotech_result/$each/08.CellChat/sample_${each}_neteach.png; label = \"${each}\">\n";
        $arf_en.="file =  <url = IDBiotech_result/$each/08.CellChat/sample_${each}_neteach.png; label = \"${each}\">\n";
    }
    $arf_cn.="size = <width = 800>\ndesc=\"连线越粗表示两个cluster之间的互作越强。\"\n";
    $arf_en.="size = <width = 800>\ndesc=\"The thicker the connection line, the stronger the interaction between two clusters\"\n";
    $nfigure++;
    $nreference++;
}







# ### Annotation ###
# my $tmp_nfig=$nfigure+1;
# if($step=~/5/){
#     foreach my $each(@samples){
# #    system("mkdir -p $IDBiotech_result/$each/05.Annotation/SciBet");
#         # system("mkdir -p $IDBiotech_result/$each/05.Annotation/SingleR");
#         system ("mkdir -m 755 -p $IDBiotech_result/$each/05.Annotation/SingleR") unless (-d "$IDBiotech_result/$each/05.Annotation/SingleR");
#         system("cp $indir/$each/05.Annotation/SingleR/*.png $indir/$each/05.Annotation/SingleR/*.pdf $IDBiotech_result/$each/05.Annotation/SingleR");
# #    system("cp $indir/$each/05.Annotation/SciBet/*.png $indir/$each/05.Annotation/SciBet/*.pdf $IDBiotech_result/$each/05.Annotation/SciBet");
#     }
#     $arf_cn.="\n\@subtitle\nnumber = $subtitle\n细胞类群注释分析\n\@paragraph\n通过聚类分析得到不同细胞类群后，除了使用每个cluster的Marker基因信息对细胞类群进行初步的注释和分析之外，还可通过其他软件将细胞类群与参考数据库进行比较，以得到分群后不同细胞的细胞类群注释信息。\nSingleR细胞注释\nSingleR\\reference{$nreference}可以将细胞聚类结果中的每个cluster与参考数据库进行比较，根据该cluster与参考数据库中已知细胞类群基因表达谱的相似性对cluster进行打分，最终得到一个打分矩阵。通过打分矩阵结果即可将细胞聚类结果注释为不同的细胞类群。细胞类群的打分矩阵结果见图$nfigure，细胞类群注释结果见图$tmp_nfig。\n";
#     $arf_en.="\n\@subtitle\nnumber = $subtitle\nAnnotation of Cell Clusters\n\@paragraph\nAfter dividing cells into different groups through cluster analysis, cell types are further identified by using marker gene information in public databases.\nSingleR Cell Annotation\nSingleR\\reference{$nreference}can recognize the existing cell clustering results based on Seurat, compare each cluster with a reference data set, and score the cluster according to the similarity of gene expression between cluster and known cell groups in the reference data set to obtain a scoring matrix. Cells/Bins can be annotated into different groups by scoring matrix results. The visualization results of the scoring matrix of cell clustering results are shown in Figure $nfigure, and the annotation results of cell groups are shown in Figure $tmp_nfig.\n";
#     $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SingleR细胞类群注释打分热图\"\n";
#     $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Scoring heatmap of cell cluster annotation by SingleR\"\n";
#     foreach my $each(@samples){
#         $arf_cn.="file =  <url = IDBiotech_result/$each/05.Annotation/SingleR/${each}_SingleR.CellClusterScoreHeatmap.png; label = \"${each}\">\n";
#         $arf_en.="file =  <url = IDBiotech_result/$each/05.Annotation/SingleR/${each}_SingleR.CellClusterScoreHeatmap.png; label = \"${each}\">\n";
#     }
#     $arf_cn.="size = <width = 768>\ndesc=\"横坐标为细胞聚类结果的cluster，纵坐标为参考数据集中包含的细胞类型，每一格颜色越接近黄色表示打分越高；最上方Labels表示SingleR给出的细胞注释结果\"\n";
#     $arf_en.="size = <width = 768>\ndesc=\"x-axis, the cell clusters; y-axis, cell types contained in the reference dataset; the color ranges from blue to yellow, and the more closer to yellow, the higher scores; top lables represent the annotation result by SingleR.\"\n";
#     $nfigure++;
#     $nreference++;

#     $arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SingleR细胞类群注释结果图\"\n";
#     $arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Annotation results of cell clusters by SingleR\"\n";
#     foreach my $each(@samples){
#         $arf_cn.="file = <url = IDBiotech_result/$each/05.Annotation/SingleR/${each}_SingleR.scaleUMAP.png; label = \"${each}\">\n";
#         $arf_en.="file = <url = IDBiotech_result/$each/05.Annotation/SingleR/${each}_SingleR.scaleUMAP.png; label = \"${each}\">\n";
#     }
#     $arf_cn.="size = <width = 768; height = 350>\ndesc=\"左图，UMAP细胞聚类结果图；右图，细胞类群在组织上的空间位置。每一种颜色代表SingleR注释得到的一种细胞类群。 \"\n";
#     $arf_en.="size = <width = 768; height = 350>\ndesc=\"Left, cluster results of UMAP; Right, spatial locations of cell types on the tissue. Each color represents a cell cluster annotaed by SingleR.\"\n";
#     $nfigure++;

# #$tmp_nfig=$nfigure+1;
# #$arf_cn.="\n\@paragraph\nSciBet细胞注释\nSciBet\\reference{$nreference}是一种基于有监督算法的细胞类群注释工具，软件中自带了基于参考数据库的模型训练结果，随后将输入的细胞聚类结果中的每个cluster进行分别建模，通过最大似然法对建模结果进行评估，同时筛选不同细胞类群中的差异基因。细胞类群注释结果见图$nfigure，细胞类群注释结果差异基因表达热图结果见图$tmp_nfig。\n";
# #$arf_en.="\n\@paragraph\nSciBet Cell Annotation\nSciBet\\reference{$nreference} comes with model training results based on reference data sets. In operation, each cluster result is modeled separately and then evaluated based on a maximum likelihood method. In the training process, SciBet uses E-test in the software to screen for different genes in different cell groups. Because of the existing trained models within SciBet, SciBet performs analysis more quickly compared with other cell group annotation software. SciBet has also been widely used in single cell sequencing data analysis and spatiotemporal omics data analysis. The annotation results of cell groups are shown in Figure $nfigure, and the differential gene expression profile results of cell group annotation results are shown in Figure $tmp_nfig.\n"
# #$nreference++;

# #$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SciBet细胞类群注释结果图\"\n";
# #$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Annotation results of SciBet cell group\"\n";
# #foreach my $each(@samples){
# #    $arf_cn.="file =  <url = IDBiotech_result/$each/05.Annotation/SciBet/${each}_SciBet.scaleUMAP.png; label = \"${each}\">\n";
# #    $arf_en.="file =  <url = IDBiotech_result/$each/05.Annotation/SciBet/${each}_SciBet.scaleUMAP.png; label = \"${each}\">\n";
# #}
# #$arf_cn.="size = <width = 768; height = 300>\ndesc=\"每一种颜色代表SciBet注释得到的一种细胞类群。 \"\n";
# #$arf_en.="size = <width = 768; height = 300>\ndesc=\"Each color represents a cell class. \"\n";
# #$nfigure++;

# #$arf_cn.="\@figure\nnumber = $nfigure\ntitle = \"SciBet细胞类群注释结果差异基因表达热图\"\n";
# #$arf_en.="\@figure\nnumber = $nfigure\ntitle = \"Heatmap of differential gene expression profiles of SciBet cell group annotation results\"\n";
# #foreach my $each(@samples){
# #    $arf_cn.="file =  <url = IDBiotech_result/$each/05.Annotation/SciBet/${each}_SciBet.CellgeneHeatmap.png; label = \"${each}\">\n";
# #    $arf_en.="file =  <url = IDBiotech_result/$each/05.Annotation/SciBet/${each}_SciBet.CellgeneHeatmap.png; label = \"${each}\">\n";
# #}
# #$arf_cn.="size = <width = 2000>\ndesc=\"横坐标为细胞类群，纵坐标为Top差异基因；每个点代表该基因在当前细胞类群中的表达情况，颜色由蓝色到红色，表达差异更显著；点由小到大，表达差异更显著。\"\n";
# #$arf_en.="size = <width = 2000>\ndesc=\"\x-axis, the cell clusters; y-axis, cell types contained in the reference dataset; the color ranges from blue to yellow, and the more closer to yellow, the higher scores; top lables represent the annotation result by SingleR.\"\n";
# #$nfigure++;
# }







open ARF_CN,">$outdir/HTML_report/arf/results_cn.arf";
open ARF_EN,">$outdir/HTML_report/arf/results_en.arf";
print ARF_CN "$arf_cn\n";
print ARF_EN "$arf_en\n";
close ARF_CN;
close ARF_EN;

system ("cp /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/arf_demo/* $outdir/HTML_report/arf");
system ("cp /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/resource_demo/* $outdir/HTML_report/resource");
system ("cp /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/report.txt $outdir/HTML_report/report.txt.temp");
system ("cp $pinfo $outdir/HTML_report/report.txt.temp"); 
system ("cp /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/arf2html.STOmics.sh $outdir/HTML_report");
system ("chmod 755 $outdir/HTML_report/arf2html.STOmics.sh"); # easy to erro

sub usage{
    print STDERR"\e[;35;3m
        ---------------   Version    --------------
        Author:   Rui Zhang
        Email:    zhangrui7\@genomics.cn
        Update:   2021.11
        -------------   Description   -------------
        An auto-html report pipeline for 10X Chromium scRNA-seq analysis, containg:
        01.Filter, 02.GeneExpMatrix, 03.Cluster, 07.Monocle, 
        05.Annotation, 08.CellChat, 07.GO_KEGG

        \e[;33;3m    -------------   Parameters    -------------
       *-sample             all sample IDs, split by space or comma;
        -bin                bin size, same with analysis;
        -step               default 1234567, 01-07 all reported;
        -indir	            the directory that contains all samples, default `pwd`;
        -outdir             the output directory, default `pwd`/HTML_report;
        -help               print usage informartion;
        ---------------   Example   ---------------
        perl $0 -sample sample1,sample2,sample3 -bin 50  \n\n \e[;32;3m
        perl $0 -sample sample1,sample2,sample3 -bin 50 -step 12346 \n\n \e[;32;3m";
    return;
}
