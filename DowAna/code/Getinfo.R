# R script used to analysize sample.list
options(warn = -1)
options(timeout = 1000)
rm(list=ls())
suppressPackageStartupMessages({
  if(!require(dplyr,quietly = TRUE)){install.packages("dplyr")}
  if(!require(argparse,quietly = TRUE)){install.packages("argparse")}
})

parser = argparse::ArgumentParser(description = 'Script for piepeline plot result ')
parser$add_argument('-f', '--samplefile', dest = 'samplefile', help = 'sample.list file name')
parser$add_argument('-o', '--outpath', dest = 'outpath', help = 'output file path')
opts = parser$parse_args()

#=============================================================================================================================
samplefile = opts$samplefile
outpath = opts$outpath
if (!dir.exists(outpath)) {
  dir.create(outpath, recursive = TRUE)
}

# read data
tmpsamplefile = read.table(samplefile,sep="\t",header=T)

# table 1
###########################################################################################################
table1 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Number of Reads" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Valid Barcodes" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Q30 Bases in Barcode" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Q30 Bases in RNA Read" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)
    f5= system(command= paste0('grep -i "Q30 Bases in UMI" ',datainfo[3],'/07.report/3.cDNA_sequencing_report.csv | cut -d "," -f 2'),intern=T)

    # character to numeric 
    f1 = as.numeric(gsub("%$","",f1))
    f2 = as.numeric(gsub("%$","",f2))
    f3 = as.numeric(gsub("%$","",f3))
    f4 = as.numeric(gsub("%$","",f4))
    f5 = as.numeric(gsub("%$","",f5))

    c(samplename,f1,f2,f3,f4,f5)
})))

table1[,2:ncol(table1)] <- apply(table1[,-1],2,function(x){as.numeric(x)})
table1 <- aggregate(.~Samplename,data=table1,FUN=mean)
table1$V2 <- formatC(table1$V2,format="f", big.mark = ",", digits=0) # add ,
table1$V3 <- formatC(table1$V3,format="f", big.mark = ",", digits=0) # add ,
table1[,4:ncol(table1)] <- apply(table1[,-c(1:3)],2,function(x){paste0(round(x,2),"%")})

colnames(table1) <- c("Sample","Number of Fragments","Valid Barcodes","Q30 Bases in Barcode","Q30 Bases in RNA Read","Q30 Bases in UMI")
write.table(table1,file=paste0(outpath,"/QC.xls"),quote=F,sep="\t",col.names=T,row.names=F)

# table 2
###########################################################################################################
table2 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Reads Mapped Confidently to Genome" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Reads Mapped Confidently to Exonic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Reads Mapped Confidently to Intronic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Reads Mapped Confidently to Intergenic Regions" ',datainfo[3],'/07.report/5.anno_report.csv | cut -d "," -f 2'),intern=T)
    # character to numeric 
    f1 = as.numeric(gsub("%$","",f1))
    f2 = as.numeric(gsub("%$","",f2))
    f3 = as.numeric(gsub("%$","",f3))
    f4 = as.numeric(gsub("%$","",f4))

    c(samplename,f1,f2,f3,f4)
})))

table2[,2:ncol(table2)] <- apply(table2[,-1],2,function(x){as.numeric(x)})
table2 <- aggregate(.~Samplename,data=table2,FUN=mean)
table2[,2:ncol(table2)] <- apply(table2[,-1],2,function(x){paste0(round(x,2),"%")})
colnames(table2) <- c("Sample","Mapping Mapped to Genome","Reads Mapped to Exonic Regions","Reads Mapped to Intronic Regions","Reads Mapped to Intergenic Regions")
write.table(table2,file=paste0(outpath,"/Mapping.xls"),quote=F,sep="\t",col.names=T,row.names=F)

# table 3
###########################################################################################################
table3 <- data.frame(t(apply(tmpsamplefile,1,function(datainfo){
    samplename=datainfo[1]
    # libname=datainfo[2]
    f1= system(command= paste0('grep -i "Estimated Number of Cells" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f2= system(command= paste0('grep -i "Mean Reads per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f3= system(command= paste0('grep -i "Median Genes per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f4= system(command= paste0('grep -i "Total Genes Detected" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)
    f5= system(command= paste0('grep -i "Median UMI Counts per Cell" ',datainfo[3],'/07.report/1.cell_report.csv | cut -f 2'),intern=T)

    # character to numeric 
    f1 = as.numeric(gsub("%$","",f1))
    f2 = as.numeric(gsub("%$","",f2))
    f3 = as.numeric(gsub("%$","",f3))
    f4 = as.numeric(gsub("%$","",f4))
    f5 = as.numeric(gsub("%$","",f5))


    c(samplename,f1,f2,f3,f4,f5)
})))
table3[,2:ncol(table3)] <- apply(table3[,-1],2,function(x){as.numeric(x)})
table3 <- aggregate(.~Samplename,data=table3,FUN=mean)
table3[,2:ncol(table3)] <- apply(table3[,-1],2,function(x){formatC(x,format="f", big.mark = ",", digits=0)})
colnames(table3) <- c("Sample","Estimated Number of Cells","Mean Reads per Cell","Median Genes per Cell","Total Genes Detected","Median UMI Counts per Cell")
write.table(table3,file=paste0(outpath,"/Cell.xls"),quote=F,sep="\t",col.names=T,row.names=F)

# generate Plot sample.sh
###########################################################################################################
# create sample result file 
samplelist <- unique(tmpsamplefile$Samplename)
for(i in 1:length(samplelist)){
    tmp.sample <- samplelist[i]
    # create  result file 
    dir.create(paste0(outpath,"/",tmp.sample))
    tmp.info <- tmpsamplefile[which(tmpsamplefile$Samplename==tmp.sample),]
    tmp.info$Respath <- paste0(outpath,"/",tmp.sample)
    
    write.table(tmp.info,file=paste0(outpath,"/",tmp.sample,"/tmp.sample.info"),sep="\t",quote=F,row.names=F,col.names=T)
    
    # copy data resport
    # sampleinfo[4] hava changed into organism
    dir.create(paste0(outpath,"/",tmp.sample,"/01.Data_report"))
    apply(tmp.info,1,function(sampleinfo){
        dir.create(paste0(sampleinfo[6],"/","01.Data_report/",sampleinfo[2])) # when sample.list add a column ,this need to plus one
        librespath = paste0(sampleinfo[6],"/","01.Data_report/",sampleinfo[2])
        system(command=paste0('cp ',sampleinfo[3],'/07.report/* ',librespath,'/'),intern=F)
    })
    
}
