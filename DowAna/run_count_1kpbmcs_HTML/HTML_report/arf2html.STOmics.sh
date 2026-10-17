
# arf2html.sh
# change template files
## 加载环境
# export LD_LIBRARY_PATH=/usr/lib64/:$LD_LIBRARY_PATH
# add libenca.so
export LD_LIBRARY_PATH=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/enca/lib/:$LD_LIBRARY_PATH
#source   /share/appspace_data/shared_groups/BGI/01.Softwares/03.Soft_ALL/SourceMe.sh # add dos2unix 
## 将文本转成HTML格式
# perl /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/bin/arf2html.STOmics.pl -i ./arf/ -d ./ -t /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/template

/bin/perl /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/arf2html.STOmics.pl -i ./arf/ -d ./ -t /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/template


