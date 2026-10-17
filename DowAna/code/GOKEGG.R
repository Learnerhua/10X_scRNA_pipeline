rm(list=ls())
options(timeout = 1000)
options(future.globals.maxSize = 1024^3) #设置全局变量的最大值为1G
options(mc.cores = 14)
suppressPackageStartupMessages({
  if(!require(Seurat,quietly = TRUE)){install.packages("Seurat")}
  if(!require(ggplot2,quietly = TRUE)){install.packages("ggplot2")}
  if(!require(stringr,quietly = TRUE)){(install.packages("stringr"))}
  if(!require(clusterProfiler,quietly = TRUE)){BiocManager::install("clusterProfiler")}
})

# function 
GOKEGGAnalysis <- function(tmpdeg,respath,name="Cluster0",FCthreshold = 0,Pthreshold = 0.05,GOOrg="org.Hs.eg.db",KEGGOrg="hsa"){

	# gene symbol to gene id 
	tmpgene <- unique(tmpdeg[which(tmpdeg$avg_log2FC>FCthreshold & tmpdeg$p_val_adj < Pthreshold),"gene"])
	eg <- bitr(tmpgene,fromType = 'SYMBOL',
			toType = c('ENTREZID'),
			OrgDb = GOOrg, #org.Mm.eg.db org.Hs.eg.db
	)
	if (length(eg) > 0){
	#=====================================================================================================
	# GO enrichment 
	enrich.goup <- enrichGO(gene = eg[,"ENTREZID"],  #待富集的基因列表
		OrgDb = GOOrg,  # 
		keyType = 'ENTREZID',  # 指定给定的基因名称类型，例如这里以 entrze id 为例
		ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
		pAdjustMethod = 'fdr',  #指定 p 值校正方法
		pvalueCutoff = 0.05,  #指定 p 值阈值（可指定 1 以输出全部） #指定 q 值阈值（可指定 1 以输出全部）
		readable = FALSE)
  
	goBP <- na.omit(subset(enrich.goup@result,subset = (ONTOLOGY == "BP"))[1:10,])
	goCC <- na.omit(subset(enrich.goup@result,subset = (ONTOLOGY == "CC"))[1:10,])
	goMF <- na.omit(subset(enrich.goup@result,subset = (ONTOLOGY == "MF"))[1:10,])
	go.df <- rbind(goBP,goCC,goMF)
  
	if (nrow(go.df) > 0){
	go.df$Description <- factor(go.df$Description,levels = rev(go.df$Description))
	# 绘图
	go_bar <- ggplot(data = go.df, # 绘图使用的数据
		aes(x = Description, y = Count,fill = ONTOLOGY))+ # 横轴坐标及颜色分类填充
			geom_bar(stat = "identity",width = 0.9)+ # 绘制条形图及宽度设置
			coord_flip()+theme_bw()+ # 横纵坐标反转及去除背景色
			scale_x_discrete(labels = function(x) stringr::str_wrap(x,width = 50))+ # 设置term名称过长时换行
			labs(x = "GO terms",y = "GeneNumber",title = "Barplot of Enriched GO Terms")+ # 设置坐标轴标题及标题
			theme(axis.title = element_text(size = 13), # 坐标轴标题大小
				axis.text = element_text(size = 11), # 坐标轴标签大小
				plot.title = element_text(size = 14,hjust = 0.5,face = "bold"), # 标题设置
				legend.title = element_text(size = 13), # 图例标题大小
				legend.text = element_text(size = 11), # 图例标签大小
				plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm")) # 图边距
	ggsave(go_bar,filename = paste0(respath,"/",name,"_GO_Barplot.png"),width = 9,height = 7)
	ggsave(go_bar,filename = paste0(respath,"/",name,"_GO_Barplot.pdf"),width = 9,height = 7)
}
	# save GO enrich result
	if (nrow(enrich.goup) > 0){
	enrich.goup_SYMBOL <- DOSE::setReadable(enrich.goup,OrgDb = GOOrg,keyType = "ENTREZID")
	write.table(enrich.goup_SYMBOL@result,file=paste0(respath,"/",name,"_GO_annotation.xls"),sep="\t",row.names=T,col.names=T,quote=F)
}

	#=================================================================================================
	# KEGG enrichment
	keggup <- enrichKEGG(gene = eg[,"ENTREZID"],  #基因列表文件中的基因名称
		keyType = 'kegg',  #KEGG 富集
		organism = KEGGOrg,  # organism
		pAdjustMethod = 'fdr',  #指定 p 值校正方法
		pvalueCutoff = 0.05)  #指定 p 值阈值（可指定 1 以输出全部）)  #指定 q 值阈值（可指定 1 以输出全部）

	# plot result 
	kegg.df <- na.omit(keggup@result[1:10,])
	if (nrow(kegg.df) > 0){
	kegg.df$Description <- factor(kegg.df$Description,levels = rev(kegg.df$Description))
	# 绘图
	kegg_bar <- ggplot(data = kegg.df, # 绘图使用的数据
		aes(x = Description, y = Count,fill = -log10(qvalue)))+ # 横轴坐标及颜色分类填充
			geom_bar(stat = "identity",width = 0.9)+ # 绘制条形图及宽度设置
			coord_flip()+theme_bw()+ # 横纵坐标反转及去除背景色
			scale_x_discrete(labels = function(x) stringr::str_wrap(x,width = 50))+ # 设置term名称过长时换行
			labs(x = "KEGG pathways",y = "GeneNumber",title = "Barplot of Enriched KEGG pathways")+ # 设置坐标轴标题及标题
			theme(axis.title = element_text(size = 13), # 坐标轴标题大小
				axis.text = element_text(size = 11), # 坐标轴标签大小
				plot.title = element_text(size = 14,hjust = 0.5,face = "bold"), # 标题设置
				legend.title = element_text(size = 13), # 图例标题大小
				legend.text = element_text(size = 11), # 图例标签大小
				plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm")) # 图边距
	ggsave(kegg_bar,filename = paste0(respath,"/",name,"_KEGG_Barplot.png"),width = 9,height = 7)
	ggsave(kegg_bar,filename = paste0(respath,"/",name,"_KEGG_Barplot.pdf"),width = 9,height = 7)
}
	# write out result 
	if (nrow(keggup) > 0) {
	keggup_SYMBOL <- DOSE::setReadable(keggup,OrgDb = GOOrg,keyType = "ENTREZID")
	write.table(keggup_SYMBOL@result,file=paste0(respath,"/",name,"_KEGG_annotation.xls"),sep="\t",row.names=T,col.names=T,quote=F)
}}}

#============================================================================================================

parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'tmp.sample.info file')
parser$add_argument('-c', '--foldchange', dest = 'foldchange',type="double", default=0.25, help = 'Log2 Fold change threshold')
parser$add_argument('-v', '--pvalue', dest = 'pthreshold',type="double", default=0.05, help = 'Adjust Pvalue threshold ')
opts = parser$parse_args()

## pramas
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

# dependence
orgpath <- paste0(outpath,"/../../code/dependence/Org_list")
orgfile <- read.table(paste0(orgpath),header=T,sep="\t")
KEGGOrg <- orgfile[which(orgfile$organism==Org),"keggname"]
GOOrg <- orgfile[which(orgfile$organism==Org),"orgdb"]
if (!requireNamespace(GOOrg, quietly = TRUE)) {
  BiocManager::install(GOOrg)
}
library(GOOrg, character.only = TRUE)

#===============================================================================================
dir.create(paste0(outpath,"/","05.GOKEGG"))
tmprespath = paste0(outpath,"/","05.GOKEGG","/")
degdata <- read.table(paste0(outpath,"/","04.sSample","/","sample_",samplename,"_pos_Markers.xls"),sep="\t",header=T)

# run for each cluster 
# set regulation 
FCthreshold = as.numeric(opts$foldchange)
Pthreshold = as.numeric(opts$pthreshold) # adjust.Pvalue

clusterlist <- unique(degdata$cluster)

clusterlist <- unique(degdata$cluster)

sapply(clusterlist,function(x){
  tmpdeg <- degdata[which(degdata$cluster==x),]
  clustername <- paste0("Cluster",x)
  GOKEGGAnalysis(tmpdeg=tmpdeg,respath=tmprespath,name=clustername,FCthreshold=FCthreshold,Pthreshold=Pthreshold,GOOrg=GOOrg,KEGGOrg=KEGGOrg)
})

