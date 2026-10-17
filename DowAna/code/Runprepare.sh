#!/bin/bash

while getopts "F:O:" opt
do
    case $opt in
        F)
            samplefile=$OPTARG
        ;;
        O)
            outdir=$OPTARG
            # echo "outdir is ${outdir} "
        ;;
        *)
            echo "check input"
        exit 1
        ;;
    esac 
done

Rscript_path=/oldhome/ouyjh/miniconda3/bin/Rscript
code_path=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code


#Part1
##################################################################################
##################################################################################
if [ ! -d ${outdir} ];then
	mkdir -p ${outdir}
fi

echo
echo "Run Getinfo.R ......"
echo

${Rscript_path} ${code_path}/Getinfo.R \
-f ${samplefile} \
-o ${outdir}

#Part 2
###################################################################################
###################################################################################
echo
echo "Generating bash scripts ......"
echo

mkdir -p ${outdir}/code
for samplename in `awk -F "\t" 'FNR>1 {print $1}' ${samplefile} | sort -u` ;
do

step=`awk -v samplename=${samplename} -F "\t" '$1==samplename {print $5}' ${samplefile} | sort -u`

if [[ $step =~ 1 ]]; then
# Pipeline_plot.R
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/Pipeline_plot_${samplename}.sh
echo "" >> ${outdir}/code/Pipeline_plot_${samplename}.sh
echo "${Rscript_path} ${code_path}/Pipeline_plot.R \\
    -f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/Pipeline_plot_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/Pipeline_plot_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/Pipeline_plot_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/Pipeline_plot_${samplename}.sh.sign" >> ${outdir}/code/Pipeline_plot_${samplename}.sh
fi

if [[ $step =~ 2 ]]; then
# Decontamination.R
touch ${outdir}/code/Decontamination_${samplename}.sh
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/Decontamination_${samplename}.sh
echo "" >> ${outdir}/code/Decontamination_${samplename}.sh
echo "${Rscript_path} ${code_path}/Decontamination.R \\
    -f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/Decontamination_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/Decontamination_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/Decontamination_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/Decontamination_${samplename}.sh.sign" >> ${outdir}/code/Decontamination_${samplename}.sh
fi

if [[ $step =~ 3 ]]; then
# single sample .R
touch ${outdir}/code/Singlesample_${samplename}.sh
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/Singlesample_${samplename}.sh
echo "" >> ${outdir}/code/Singlesample_${samplename}.sh
echo "${Rscript_path} ${code_path}/SingleSample.R \\
    -f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/Singlesample_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/Singlesample_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/Singlesample_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/Singlesample_${samplename}.sh.sign" >> ${outdir}/code/Singlesample_${samplename}.sh
fi

if [[ $step =~ 4 ]]; then
# GOKEGG .R
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/GOKEGG_${samplename}.sh
echo "" >> ${outdir}/code/GOKEGG_${samplename}.sh
echo "${Rscript_path} ${code_path}/GOKEGG.R \\
-f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/GOKEGG_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/GOKEGG_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/GOKEGG_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/GOKEGG_${samplename}.sh.sign" >> ${outdir}/code/GOKEGG_${samplename}.sh
fi


if [[ $step =~ 5 ]]; then
# SingleR .R
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/SingleR_${samplename}.sh
echo "" >> ${outdir}/code/SingleR_${samplename}.sh
echo "${Rscript_path} ${code_path}/SingleR.R \\
-f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/SingleR_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/SingleR_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/SingleR_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/SingleR_${samplename}.sh.sign" >> ${outdir}/code/SingleR_${samplename}.sh
fi


if [[ $step =~ 6 ]]; then
# Monocle .R
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/Monocle_${samplename}.sh
echo "" >> ${outdir}/code/Monocle_${samplename}.sh
echo "${Rscript_path} ${code_path}/Monocle.R \\
-f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/Monocle_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/Monocle_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/Monocle_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/Monocle_${samplename}.sh.sign" >> ${outdir}/code/Monocle_${samplename}.sh
fi


if [[ $step =~ 7 ]]; then
# CellChat .R
echo "echo ==========start at : \`date\` ==========" > ${outdir}/code/CellChat_${samplename}.sh
echo "" >> ${outdir}/code/CellChat_${samplename}.sh
echo "${Rscript_path} ${code_path}/CellChat.R \\
-f ${outdir}/${samplename}/tmp.sample.info && \\" >> ${outdir}/code/CellChat_${samplename}.sh
echo "echo ==========end at : \`date\` ========== && \\" >> ${outdir}/code/CellChat_${samplename}.sh
echo "echo Still_waters_run_deep 1>&2 && \\" >> ${outdir}/code/CellChat_${samplename}.sh
echo "echo Still_waters_run_deep > ${outdir}/code/CellChat_${samplename}.sh.sign" >> ${outdir}/code/CellChat_${samplename}.sh
fi
done

