### CellChat analysis ###
#========================================================================================================
suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(CellChat,quietly = TRUE)){devtools::install_github("jinworks/CellChat")}
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

Org = unique(samplefile$organism)
if(length(Org)>1){
	Org = Org[1] # should not have more than one 
}

samplename = unique(samplefile$Samplename) # also should only have one 
if(length(samplename)>1){
	samplename = samplename[1] # should not have more than one 
}

# database
if(Org=="Human"||Org=="human"){
	CellChatDB_use <- CellChatDB.human
	}else if(Org=="Mouse"||Org=="mouse"){
		CellChatDB_use <- CellChatDB.mouse
		}else{
			CellChatDB_use <- NA
			Org <- NA # set to na
}


# Cell Chat
#===========================================================================================================================
# create object
dir.create(paste0(outpath,"/","08.CellChat"))
tmprespath = paste0(outpath,"/","08.CellChat","/")

dat <- readRDS(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_data.RDS")) # load data
# degdata <- read.table(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_pos_Markers.xls"),sep="\t",header=T) #deg data for plot in pesuotime 
# add Clusters for cellchat group
dat$Clusters <- paste0("C",dat$seurat_clusters)

cellchat <- createCellChat(object = dat, meta = dat@meta.data, group.by = "Clusters")
cellchat@DB <- CellChatDB_use

cellchat <- subsetData(cellchat) # subset the expression data of signaling genes for saving computation cost

cellchat <- identifyOverExpressedGenes(cellchat)
cellchat <- identifyOverExpressedInteractions(cellchat)
# cellchat <- projectData(cellchat, PPI.human)

cellchat <- computeCommunProb(cellchat, raw.use = TRUE) # need lots of time 
# Filter out the cell-cell communication if there are only few number of cells in certain cell groups
cellchat <- filterCommunication(cellchat, min.cells = 10)

cellchat <- computeCommunProbPathway(cellchat)
cellchat <- aggregateNet(cellchat)

# saveRDS
saveRDS(cellchat,file=paste0(tmprespath,samplename,"_data_cellchat.RDS"))


# plot1 
#=============================================================================================================

groupSize <- as.numeric(table(cellchat@idents))

png(filename=paste0(tmprespath,"sample_",samplename,"_netall.png"),res=500,units="in",width = 8, height = 8)
netVisual_circle(cellchat@net$count, vertex.weight = groupSize, weight.scale = T, label.edge= F, title.name = "Number of interactions")
dev.off()

pdf(file=paste0(tmprespath,"sample_",samplename,"_netall.pdf"),width = 10, height = 10)
netVisual_circle(cellchat@net$count, vertex.weight = groupSize, weight.scale = T, label.edge= F, title.name = "Number of interactions")
dev.off()

# plot2
#=============================================================================================================
mat <- cellchat@net$weight

png(filename=paste0(tmprespath,"sample_",samplename,"_neteach.png"),res=500,units="in",width = 8, height = 8)
par(mar = c(0.5, 0.5,1, 0.5),mfrow = c(4,ceiling(nrow(mat)/4)), xpd=TRUE)
for (i in 1:nrow(mat)) {  
	mat2 <- matrix(0, nrow = nrow(mat), ncol = ncol(mat), dimnames = dimnames(mat))
	mat2[i, ] <- mat[i, ]  
	netVisual_circle(mat2, vertex.weight = groupSize, weight.scale = T,edge.weight.max = max(mat), title.name = rownames(mat)[i])
}
dev.off()


pdf(file=paste0(tmprespath,"sample_",samplename,"_neteach.pdf"),width = 10, height = 10)
par(mar = c(0.5, 0.5,1, 0.5),mfrow = c(4,ceiling(nrow(mat)/4)), xpd=TRUE)
for (i in 1:nrow(mat)) {  
	mat2 <- matrix(0, nrow = nrow(mat), ncol = ncol(mat), dimnames = dimnames(mat))
	mat2[i, ] <- mat[i, ]  
	netVisual_circle(mat2, vertex.weight = groupSize, weight.scale = T,edge.weight.max = max(mat), title.name = rownames(mat)[i])
}
dev.off()
