rm(list=ls())
options(timeout = 1000)
options(future.globals.maxSize = 1024^3) #设置全局变量的最大值为1G
options(mc.cores = 16)

### Monocle analysis ###
#========================================================================================================
suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(monocle3,quietly = TRUE)){
    devtools::install_github("cole-trapnell-lab/monocle3")}
  if(!require(SeuratWrappers,quietly = TRUE)){
    remotes::install_github('satijalab/seurat-wrappers')}
})
parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
opts = parser$parse_args()

## pramas 
# read tmp.sample.info file 
samplefile = read.table(paste0(opts$samplefile),header=T)
outpath = paste0(unique(samplefile$Respath)) #this also the data path
samplename = unique(samplefile$Samplename)[1] # also should only have one 

# Pseucotime 
#===========================================================================================================================
# create object
dir.create(paste0(outpath,"/","07.Monocle"))
tmprespath = paste0(outpath,"/","07.Monocle","/")

dat <- readRDS(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_data.RDS")) # load data
degdata <- read.table(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_pos_Markers.xls"),sep="\t",header=T) #deg data 
cds.dat <- as.cell_data_set(dat)
cds.dat <- cluster_cells(cds.dat, resolution=1e-3)

cds <- learn_graph(cds.dat, use_partition = TRUE, verbose = FALSE)
cds <- order_cells(cds, root_cells = colnames(cds[,clusters(cds) == 1]))

p1 <- plot_cells(cds,
           color_cells_by = "cluster",
           label_groups_by_cluster=TRUE,
           label_leaves=FALSE,
           label_branch_points=FALSE)

p2 <- plot_cells(cds,
           color_cells_by = "pseudotime",
           group_cells_by = "cluster",
           label_cell_groups = FALSE,
           label_groups_by_cluster=FALSE,
           label_leaves=FALSE,
           label_branch_points=FALSE,
           label_roots = FALSE,
           trajectory_graph_color = "grey60")


ggsave(filename=paste0(tmprespath,"sample_",samplename,"_track.png"),plot=p1,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_track.pdf"),plot=p1,device="pdf",dpi=500,width = 20, height = 20)

ggsave(filename=paste0(tmprespath,"sample_",samplename,"_pseudotime.png"),plot=p2,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_pseudotime.pdf"),plot=p2,device="pdf",dpi=500,width = 20, height = 20)

# DEG 
# DEG from 04.sSample

clusterlist <- unique(degdata$cluster)

sapply(clusterlist,function(x){
	tmpdeg <- head(degdata[which(degdata$cluster==x),"gene"],3)
	p3 <- plot_genes_in_pseudotime(cds[rownames(cds)%in% tmpdeg,],min_expr=0,label_by_short_name=F)

	ggsave(filename=paste0(tmprespath,"/",samplename,"_Cluster_",x,"_monocle.png"),plot=p3,device="png",dpi=500,width = 8, height = 8)
	ggsave(filename=paste0(tmprespath,"/",samplename,"_Cluster_",x,"_monocle.pdf"),plot=p3,device="pdf",dpi=500,width = 8, height = 8)
})

saveRDS(cds,file=paste0(tmprespath,"sample_",samplename,"_monocle.RDS"))
