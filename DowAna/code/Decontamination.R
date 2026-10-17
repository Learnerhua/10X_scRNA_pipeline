rm(list=ls())
options(timeout = 1000)
options(future.globals.maxSize = 1024^4) #设置全局变量的最大值为1G
options(mc.cores = 16)

suppressPackageStartupMessages({
  if(!require(BiocManager,quietly = TRUE)){install.packages("BiocManager")}
  if(!require(devtools,quietly = TRUE)){install.packages("devtools")}
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(dplyr,quietly = TRUE)){install.packages("dplyr")}
  if(!require(argparse,quietly = TRUE)){install.packages("argparse")}
  if(!require(data.table,quietly = TRUE)){install.packages("data.table")}
  if(!require(scater,quietly = TRUE)){BiocManager::install("scater")}
  if(!require(celda,quietly = TRUE)){BiocManager::install("celda")}
  if(!require(glmGamPoi,quietly = TRUE)){BiocManager::install("glmGamPoi")}
  if(!require(DoubletFinder,quietly = TRUE)){devtools::install_github('chris-mcginnis-ucsf/DoubletFinder')}
})

#============================================================================================================
parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
opts = parser$parse_args()

## pramas 

samplefile = read.table(paste0(opts$samplefile),header=T)
outpath = paste0(unique(samplefile$Respath)) #this also the data path
samplename = unique(samplefile$Samplename) # also should only have one 

# Decontamination
#=================================================================================
# create object
dir.create(paste0(outpath,"/","04.Decontamination"))
tmprespath = paste0(outpath,"/","04.Decontamination","/")
dat <- readRDS(paste0(outpath,"/","03.HvgPCA","/","sample_",samplename,"_data.RDS")) # load data
dat <- FindNeighbors(dat, dims = 1:10)
dat <- FindClusters(dat, resolution = 0.5)
dat <- RunUMAP(dat, dims = 1:10)

#=========================================================
# docontX 
dat <- JoinLayers(dat)
sce <- as.SingleCellExperiment(dat)
sce.decont <- decontX(x=sce)
# sce.decont.filter <- decontXcounts(sce.decont)  # modified matrix 

dat@meta.data$decontX_contamination <- colData(sce.decont)$decontX_contamination
# add a classified meta data
dat$decontX_class <- "L-prob"
dat$decontX_class[which(dat$decontX_contamination > quantile(dat$decontX_contamination,0.9))] <- "H-prob"

p1 <- DimPlot(dat,group.by="decontX_class")
p2 <- FeaturePlot(dat,features="decontX_contamination")

ggsave(filename=paste0("sample_",samplename,"_decontx_class.png"),path=tmprespath,plot=p1,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0("sample_",samplename,"_decontx_class.pdf"),path=tmprespath,plot=p1,device="pdf",dpi=500,width = 20, height = 20)

ggsave(filename=paste0("sample_",samplename,"_decontx_score.png"),path=tmprespath,plot=p2,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0("sample_",samplename,"_decontx_score.pdf"),path=tmprespath,plot=p2,device="pdf",dpi=500,width = 20, height = 20)


#=========================================================
# FindDoublets
homotypic.prop <- modelHomotypic(dat$seurat_clusters)   ## ex: annotations <- Adult1B@meta.data
    ## Assuming 7.5% doublet formation rate - tailor for your dataset. set for？？
nExp_poi <- round(0.05*nrow(dat@meta.data))
nExp_poi.adj <- round(nExp_poi*(1-homotypic.prop))

    ## Run DoubletFinder with varying classification stringencies
dat <- doubletFinder(dat, PCs = 1:10, pN = 0.25, pK = 0.09, nExp = nExp_poi,reuse.pANN = FALSE,sct = TRUE)
colnames(dat@meta.data)[grep("DF.classifications",colnames(dat@meta.data))] <- "DF.classifications"


p3 <- DimPlot(dat,group.by="DF.classifications")
ggsave(filename=paste0("sample_",samplename,"_doublets_dimplot.png"),path=tmprespath,plot=p3,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0("sample_",samplename,"_doublets_dimplot.pdf"),path=tmprespath,plot=p3,device="pdf",dpi=500,width = 20, height = 20)


# write all data info 
saveRDS(dat,file=paste0(tmprespath,"sample_",samplename,"_alldata.RDS"))
write.table(dat@meta.data,file=paste0(tmprespath,"sample_",samplename,"_metainfo.xls"),sep="\t",quote=F,row.names=T,col.names=T)

#=========================================================
# subset result and run PCA again

subdat <- subset(dat,subset = DF.classifications=="Singlet" & decontX_class == "L-prob")
subdat <- FindVariableFeatures(subdat, nfeatures = 2000)
all.genes <- rownames(subdat)
subdat <- ScaleData(subdat, features = all.genes)
subdat <- RunPCA(subdat, features = VariableFeatures(object = subdat)) # default is 50 PCs

saveRDS(subdat,file=paste0(tmprespath,"sample_",samplename,"_data.RDS"))
