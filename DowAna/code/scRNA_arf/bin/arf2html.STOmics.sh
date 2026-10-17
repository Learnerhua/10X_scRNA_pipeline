
# arf2html.sh
# change template files
## 加载环境
# export LD_LIBRARY_PATH=/usr/lib64/:$LD_LIBRARY_PATH
# add libenca.so
export LD_LIBRARY_PATH=/share/appspace_data/shared_groups/BGI/USERS/bgi_lily/Report/code/scRNA_arf/bin/program/enca/lib/:$LD_LIBRARY_PATH
source   /share/appspace_data/shared_groups/BGI/01.Softwares/03.Soft_ALL/SourceMe.sh # add dos2unix 
## 将文本转成HTML格式
# perl /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/bin/arf2html.STOmics.pl -i ./arf/ -d ./ -t /ldfssz1/ST_OCEAN/USER/liaoshangfeng/Pipline/HTML_arf/template

/bin/perl /share/appspace_data/shared_groups/BGI/USERS/bgi_lily/Report/code/scRNA_arf/bin/arf2html.STOmics.pl -i ./arf/ -d ./ -t /share/appspace_data/shared_groups/BGI/USERS/bgi_lily/Report/code/scRNA_arf/template


