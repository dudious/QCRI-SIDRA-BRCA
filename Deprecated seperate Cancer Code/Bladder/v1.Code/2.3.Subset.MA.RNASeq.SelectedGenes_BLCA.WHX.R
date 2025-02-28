#################################################################
###
### This Script creates a subset of the MA and RNAseq data 
### for a selected set  genes.(Gene_selection_XXX.txt)
### source data :
### "./2 DATA/TCGA BLCA MA/BLCA.MA.TCGA.ASSEMBLER.CLEANED.RData" 
### "./2 DATA/TCGA RNAseq/RNASeq_BLCA_EDASeq/BLCA.RNASeq.TCGA.ASSEMBLER.NORMALIZED.LOG2.RData"
### "./2 DATA/SUBSETS/Gene_selection_xxx.txt" (SELECTED GENES)
### Results are saved in
### ./2 DATA/SUBSETS/
### File to use :
### "TCGA.BLCA.MA.subset.16G.RData"
### "TCGA.BLCA.RNASeq.subset.16G.RData"
###
#################################################################

# Setup environment
rm(list=ls())
setwd("~/Dropbox/BREAST_QATAR")

# load data
#load ("./2 DATA/TCGA BC MA/BLCA.MA.TCGA.ASSEMBLER.CLEANED.Rdata")                                # no MA data for BLCA
load ("./2 DATA/TCGA RNAseq/RNASeq_BLCA_EDASeq/BLCA.RNASeq.TCGA.ASSEMBLER.NORMALIZED.LOG2.RData")
gene.list <- read.csv ("./2 DATA/SUBSETS/Gene_selection_INES_MA.txt")                             # Select subset here !!!!! and change filename below !!!!
gene.list.selected <- as.character(gene.list[which(gene.list[,"Selected_by_DB"]==1),1])

## Subset MA data
#dim (agilentData) #531 17814
#print ("Gene selection or Micro Array")
#MA.subset <- as.data.frame(agilentData[,1]) #subset(agilentData,select=gene.list.selected[1])
#for (i in 1:length(gene.list.selected))
#  {
#  if (gene.list.selected[i] %in% colnames(agilentData))
#    {
#    MA.subset <- cbind (MA.subset,subset (agilentData,select=gene.list.selected[i]))
#    cat(i,"Gene added :",gene.list.selected[i],"\n")  
#    }
#  else
#    { cat (i,"Gene NOT added :",gene.list.selected[i],"\n") }
#  }
#MA.subset[,1] <- NULL
#dim (MA.subset)   #531  16/18

# Subset RNASeq data
RNASeq.NORM <- t(RNASeq.NORM_Log2)
dim (RNASeq.NORM) #1095 20322
print ("Gene selection for RNASeq")
RNASeq.subset <- as.data.frame(RNASeq.NORM[,1]) #subset(agilentData,select=gene.list.selected[1])
for (i in 1:length(gene.list.selected))
{
  if (gene.list.selected[i] %in% colnames(RNASeq.NORM))
  {
    RNASeq.subset <- cbind (RNASeq.subset,subset (RNASeq.NORM,select=gene.list.selected[i]))
    cat(i,"Gene added :",gene.list.selected[i],"\n")  
  }
  else
  { cat (i,"Gene NOT added :",gene.list.selected[i],"\n") }
}
RNASeq.subset[,1] <- NULL
dim (RNASeq.subset)   #1095   16/16

# save subsetted data
#save (MA.subset,file="./2 DATA/SUBSETS/MA.subset.16G.I.ID2.RData")                #adjust output file names here !!!!!
save (RNASeq.subset,file="./2 DATA/SUBSETS/BLCA/TCGA.BLCA.RNASeq.subset.ISGS.RData")    #adjust output file names here !!!!!

