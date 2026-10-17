#!/bin/bash

set -euxo pipefail

sampleNames=(FC_1 FC_2 FC_3 FC_4 FS_1 FS_2 FS_3 FS_4)

up_dir=/Nas3Data/STProject_analysis/KM-XS-2311-094/SC_251120
down_dir=/Nas3Data/STProject_analysis/KM-XS-2311-094/SC_251120/DowAna
out_dir=/Nas3Data/STProject_analysis/KM-XS-2311-094/SC_251120/Project_output

cd ${down_dir}
rm `find *HTML -name "*RDS" | grep "/report/"`
for sample in ${sampleNames[@]};do
	
	if [ ! -d ${out_dir}/${sample} ];then
		mkdir -p ${out_dir}/${sample}
	fi

	cp -r ${up_dir}/${sample}/output/{filter_feature.h5ad,metrics_summary.xls,${sample}_scRNA_report.html,singlecell.csv,filter_matrix,raw_matrix,attachment} ${out_dir}/${sample}

	cp -r ${down_dir}/${sample}_HTML/HTML_report/report ${out_dir}/${sample}
	sed -i 's|http://lib.sinaapp.com/js/jquery/1.9.1/jquery-1.9.1.min.js|http://code.jquery.com/jquery-1.9.1.min.js|g' ${out_dir}/${sample}/*.html
done
cd ${out_dir}
for sample in ${sampleNames[@]};do
	find $sample -type f -exec md5sum {} \; > ${sample}.md5
done

