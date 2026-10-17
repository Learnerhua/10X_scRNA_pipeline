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
