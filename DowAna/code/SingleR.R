rm(list=ls())
options(timeout = 1000)
options(future.globals.maxSize = 1024^3) #设置全局变量的最大值为1G
options(mc.cores = 16)

suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(SingleR,quietly = TRUE)){BiocManager::install("SingleR")}
})
#============================================================================================
parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
opts = parser$parse_args()

## pramas 
# read tmp.sample.info file 
samplefile = read.table(paste0(opts$samplefile),header=T)
outpath = paste0(unique(samplefile$Respath)) #this also the data path

Org = unique(samplefile$organism)
if(length(Org)>1){
	Org = Org[1] # should not have more than one 
}

samplename = unique(samplefile$Samplename) # also should only have one 
if(length(samplename)>1){
	samplename = samplename[1] # should not have more than one 
}

# dependence ref data
if(Org=="Human"||Org=="human"){
	refdat <- readRDS(paste0(outpath,"/../../code/dependence/BlueprintEncodeData.rds"))
	}else if(Org=="Mouse"||Org=="mouse"){
		refdat <- readRDS(paste0(outpath,"/../../code/dependence/MouseRNAseqData.rds"))
		}else{
			refdat <- NA
			Org <- NA # set to na
}

################################################################################################
#===============================================================================================
dir.create(paste0(outpath,"/","06.SingleR"))
tmprespath = paste0(outpath,"/","06.SingleR","/")
dat <- readRDS(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_data.RDS")) # load data
sce.dat <- as.SingleCellExperiment(dat,assay="RNA")

#================================================================================================
# run singleR

if(!is.na(Org)){
  
pred.grun <- SingleR(test=sce.dat, ref=refdat, labels=refdat$label.fine,clusters=sce.dat$seurat_clusters,de.method="wilcox")
#dat$SingleR.label <-  pred.grun$pruned.labels[match(dat$seurat_clusters, rownames(pred.grun))]
cluster_labels <- setNames(pred.grun$pruned.labels, rownames(pred.grun))
cls <- as.character(dat$seurat_clusters)
dat$SingleR.label <- unname(cluster_labels[cls])
dat <- dat[, !is.na(dat@meta.data$SingleR.label)]
# save plot 
p1 <- DimPlot(dat,group.by="SingleR.label",reduction="umap")

ggsave(p1,filename = paste0(tmprespath,"/",samplename,"_DimPlot_singleR.png"),width = 9,height = 7)
ggsave(p1,filename = paste0(tmprespath,"/",samplename,"_DimPlot_singleR.pdf"),width = 9,height = 7)


p2 <- plotScoreHeatmap(pred.grun)

ggsave(p2,filename = paste0(tmprespath,"/",samplename,"_Heatmap_singleR.png"),width = 8,height = 7)
ggsave(p2,filename = paste0(tmprespath,"/",samplename,"_Heatmap_singleR.pdf"),width = 8,height = 7)

}else{
	system(command= paste0('cp ',outpath,'/04.sSample/sample_',samplename,'_fig4_cluster.png ',tmprespath,"/",samplename,"_DimPlot_singleR.png"),intern=F)
	system(command= paste0('cp ',outpath,'/04.sSample/sample_',samplename,'_fig4_cluster.png ',tmprespath,"/",samplename,"_Heatmap_singleR.png"),intern=F)

}

#=====================================================================================
# save data 
saveRDS(dat,file=paste0(tmprespath,samplename,"_data_singleR.RDS"))
