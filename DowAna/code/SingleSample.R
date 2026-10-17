rm(list=ls())
options(timeout = 1000)
options(future.globals.maxSize = 1024^3) #设置全局变量的最大值为1G
options(mc.cores = 16)

suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(dplyr,quietly = TRUE)){install.packages("dplyr")}
  if(!require(presto,quietly = TRUE)){devtools::install_github('immunogenomics/presto')}
})

parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
opts = parser$parse_args()


# pramas 
samplefile = read.table(paste0(opts$samplefile),header=T)
outpath = paste0(unique(samplefile$Respath))
samplename <- as.character(unique(samplefile$Samplename)[1])
dat <- readRDS(paste0(outpath,"/","04.Decontamination","/","sample_",samplename,"_data.RDS"))

# 04. Single sample analysis
#===========================================================================================================================
dir.create(paste0(outpath,"/","04.sSample"))
tmprespath = paste0(outpath,"/","04.sSample","/")
dat <- dat %>% FindNeighbors(dims = 1:10) %>% 
  FindClusters(resolution = 0.5) %>% 
  RunUMAP(dims = 1:10)

p4 <- DimPlot(dat, reduction = "umap")
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig4_cluster.png"),plot=p4,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig4_cluster.pdf"),plot=p4,device="pdf",dpi=500,width = 20, height = 20)

# saveRDS
saveRDS(dat,file=paste0(tmprespath,"sample_",samplename,"_data.RDS"))

# find markers
dat.clusters <- FindAllMarkers(dat, only.pos = TRUE)
dat.clusters %>%
    group_by(cluster) %>%
    slice_max(n = 3, order_by = avg_log2FC) -> top

write.table(top,file=paste0(tmprespath,"sample_",samplename,"_top3_Markers.xls"),sep="\t",row.names=F,col.names=T,quote=F)
write.table(dat.clusters,file=paste0(tmprespath,"sample_",samplename,"_pos_Markers.xls"),sep="\t",row.names=F,col.names=T,quote=F)

p5 <- DoHeatmap(dat, features = top$gene) + NoLegend()
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_heatmapClusters.png"),plot=p5,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_heatmapClusters.pdf"),plot=p5,device="pdf",dpi=500,width = 20, height = 20)


p6 <- DotPlot(dat, features = unique(top$gene)) + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=.5))
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_dotplotClusters.png"),plot=p6,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_dotplotClusters.pdf"),plot=p6,device="pdf",dpi=500,width = 20, height = 20)


p7 <- VlnPlot(dat, features = unique(top$gene),pt.size=0,stack=T) + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=.5))
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_vlnplotClusters.png"),plot=p7,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_vlnplotClusters.pdf"),plot=p7,device="pdf",dpi=500,width = 20, height = 20)
