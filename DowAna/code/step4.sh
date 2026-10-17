#!/bin/bash
set -euxo pipefail
ulimit -u 10240

major_dir=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna
replace_dir=/oldhome/luow/STProject_2023_analysis/QT2411280001/SC/DowAna
sampleNames=(run_count_1kpbmcs)

sed -i "s#${replace_dir}#${major_dir}#g" ${major_dir}/code/Pipeline_scRNA_arf.pl
sed -i "s#${replace_dir}#${major_dir}#g" ${major_dir}/code/scRNA_arf/bin/arf2html.STOmics.pl
sed -i "s#${replace_dir}#${major_dir}#g" ${major_dir}/code/scRNA_arf/bin/pdf.STOmics.sh

for sample in ${sampleNames[@]};do
	perl ${major_dir}/code/Pipeline_scRNA_arf.pl \
		-sample ${sample} \
		-pinfo ${major_dir}/Project.info \
		-indir ${major_dir}/Res/ \
		-outdir ${major_dir}/${sample}_HTML \
		-step 1234567
done

find ${major_dir}/*_HTML -name "arf2html.STOmics.sh" -exec sed -i -e "s#/share/appspace_data/shared_groups/BGI/USERS/bgi_lily/Report#${major_dir}#g" -e "8s/^/#/" {} +

for sample in ${sampleNames[@]};do
	cd ${major_dir}/${sample}_HTML/HTML_report/IDBiotech_result/
	for file in *.xls;do
		cat ${file} | perl -alne "if(\$.==1){print}else{if(\$_=~/\b${sample}\b/){print}}" > test;mv test ${file}
	done
	cd ${major_dir}/${sample}_HTML/HTML_report/
	bash arf2html.STOmics.sh > ${major_dir}/${sample}_step4.log 2>&1 &
done
cd ${major_dir}
#rm `find *HTML -name "*RDS" | grep "/report/"`
