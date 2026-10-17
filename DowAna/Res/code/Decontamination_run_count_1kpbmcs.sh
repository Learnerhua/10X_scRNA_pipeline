echo ==========start at : `date` ==========

/oldhome/ouyjh/miniconda3/bin/Rscript /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/Decontamination.R \
    -f /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/Res/run_count_1kpbmcs/tmp.sample.info && \
echo ==========end at : `date` ========== && \
echo Still_waters_run_deep 1>&2 && \
echo Still_waters_run_deep > /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/Res/code/Decontamination_run_count_1kpbmcs.sh.sign
