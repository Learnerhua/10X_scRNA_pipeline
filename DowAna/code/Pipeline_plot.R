options(timeout = 1000)
rm(list=ls())

suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(dplyr,quietly = TRUE)){install.packages("dplyr")}
  if(!require(argparse,quietly = TRUE)){install.packages("argparse")}
})


parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
opts = parser$parse_args()

# pramas 
samplefile = read.table(paste0(opts$samplefile),header=T)
outpath = paste0(unique(samplefile$Respath))

# 0. Create Seurat object
# make sure ncol
if(nrow(samplefile)>1){
    dat.list <- list()
    libdatapath <- as.character(samplefile$datapath)
    samplename <- as.character(unique(samplefile$Samplename))
    for(i in 1:length(libdatapath)){
        tmp.data.path <- paste0(libdatapath[i],"/04.Matrix/FilterMatrix/")
        # create  result file 
        tmpcount <- Read10X(data.dir=paste0(tmp.data.path),gene.column=2) # make sure input file gene.column
        tmpdat <- CreateSeuratObject(counts = tmpcount, project = samplename, min.cells = 3, min.features = 200) # default parma
        tmpdat[["percent.mt"]] <- PercentageFeatureSet(tmpdat, pattern = "^MT-|^Mt-")
        dat.list[[i]] <- tmpdat
    }
    dat <- merge(x=dat.list[[1]],y=dat.list[2:length(dat.list)])
}else{
    samplename <- as.character(unique(samplefile$Samplename))
    libdatapath <- as.character(samplefile$datapath)[1]
    tmp.data.path <- paste0(libdatapath,"/04.Matrix/FilterMatrix/")
    tmpcount <- Read10X(data.dir=paste0(tmp.data.path),gene.column=2) # make sure input file gene.column
    dat <- CreateSeuratObject(counts = tmpcount, project = samplename, min.cells = 3, min.features = 200) # default parma
    dat[["percent.mt"]] <- PercentageFeatureSet(dat, pattern = "^MT-|^Mt-|^mt-")
}

# 02.Normalize
#============================================================================================================================
dir.create(paste0(outpath,"/","02.Normalize"))
tmprespath = paste0(outpath,"/","02.Normalize","/")

# scatterplot
dat@meta.data$percent.mt


plot1 <- FeatureScatter(dat, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(dat, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
p <- plot1 + plot2
ggsave(filename=paste0("sample_",samplename,"_fig1_scatterplot.png"),path=tmprespath,plot=p,device="png",dpi=500,width = 20, height = 20)
ggsave(filename=paste0("sample_",samplename,"_fig1_scatterplot.pdf"),path=tmprespath,plot=p,device="pdf",dpi=500,width = 20, height = 20)
rm(list=c("plot1","plot2","p"))

# vlnplot
p <- VlnPlot(dat, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
ggsave(filename=paste0("sample_",samplename,"_fig1_vlnplot.png"),path=tmprespath,plot=p,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0("sample_",samplename,"_fig1_vlnplot.pdf"),path=tmprespath,plot=p,device="pdf",dpi=500,width = 20, height = 20)
rm("p")


# 03. HvgPCA
#============================================================================================================================
dir.create(paste0(outpath,"/","03.HvgPCA"))
tmprespath = paste0(outpath,"/","03.HvgPCA","/")

dat <- NormalizeData(dat)
dat <- FindVariableFeatures(dat, nfeatures = 2000)
all.genes <- rownames(dat)
dat <- ScaleData(dat, features = all.genes)
dat <- RunPCA(dat, features = VariableFeatures(object = dat)) # default is 50 PCs

# variable features plot
p2 <- LabelPoints(plot = VariableFeaturePlot(dat), points = head(VariableFeatures(dat), 10), repel = TRUE)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_var.png"),plot=p2,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_var.pdf"),plot=p2,device="pdf",dpi=500,width = 20, height = 20)


# elbowplot 
p3 <- ElbowPlot(dat, ndims = 15)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_elbowplot.png"),plot=p3,device="png",dpi=500,width = 8, height = 8)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_elbowplot.pdf"),plot=p3,device="pdf",dpi=500,width = 20, height = 20)

p4 <- DimHeatmap(dat, dims = 1:15, cells = 500, balanced = TRUE,fast=F)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_pca.png"),plot=p4,device="png",dpi=500,width = 20, height = 20)
ggsave(filename=paste0(tmprespath,"sample_",samplename,"_fig3_pca.pdf"),plot=p4,device="pdf",dpi=500,width = 20, height = 20)

saveRDS(dat,file=paste0(tmprespath,"sample_",samplename,"_data.RDS"))
