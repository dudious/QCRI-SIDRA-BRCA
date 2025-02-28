#################################################################
###
### This Script creates a subset of the MA and RNAseq data 
### for a selected set  genes.(Gene_selection_XXX.txt)
### source data :
### "./2 DATA/TCGA COAD MA/COAD.MA.TCGA.ASSEMBLER.CLEANED.RData" 
### "./2 DATA/TCGA RNAseq/RNASeq_COAD_EDASeq/COAD.RNASeq.TCGA.ASSEMBLER.NORMALIZED.LOG2.RData"
### "./2 DATA/SUBSETS/Gene_selection_xxx.txt" (SELECTED GENES)
### Results are saved in
### ./2 DATA/SUBSETS/
### File to use :
### "TCGA.COAD.MA.subset.16G.RData"
### "TCGA.COAD.RNASeq.subset.16G.RData"
###
#################################################################

# Setup environment
rm(list=ls())
setwd("~/Dropbox/BREAST_QATAR")

dir.create("./2 DATA/SUBSETS/COAD/", showWarnings = FALSE)

# load data
#load ("./2 DATA/TCGA BC MA/COAD.MA.TCGA.ASSEMBLER.CLEANED.Rdata")                                # no MA data for COAD
load ("./2 DATA/TCGA RNAseq/RNASeq_COAD_EDASeq/COAD.RNASeq.TCGA.ASSEMBLER.hiseq.NORMALIZED.LOG2.RData")
gene.list <- read.csv ("./2 DATA/SUBSETS/Gene_selection_INES_MA.txt")                             # Select subset here !!!!! and change filename below !!!!
gene.list.selected <- as.character(gene.list[which(gene.list[,"Selected_by_DB"]==1),1])

# check availabilety of the genes in the dataset
#available.genes.MA <- gene.list.selected[which(gene.list.selected %in% rownames(agilentData))]
#unavailable.genes.MA <- gene.list.selected[-which(gene.list.selected %in% rownames(agilentData))]
available.genes.RNAseq <- gene.list.selected[which(gene.list.selected %in% rownames(RNASeq.NORM_Log2))]
unavailable.genes.RNAseq <- gene.list.selected[-which(gene.list.selected %in% rownames(RNASeq.NORM_Log2))]

## Subset data
#MA.subset <- agilentData[available.genes.RNAseq,]
RNASeq.subset <- t(RNASeq.NORM_Log2[available.genes.RNAseq,])

## report
#print (paste0("Genes selected for MicroArray :",available.genes.MA))
#print (paste0("Genes missing for MicroArray  :",unavailable.genes.MA))
print ("Genes selected for RNASeq : ")
print(available.genes.RNAseq)
print ("Genes missing for RNASeq :")
print(unavailable.genes.RNAseq)

# save subsetted data
#save (MA.subset,file="./2 DATA/SUBSETS/MA.subset.16G.I.ID2.RData")                #adjust output file names here !!!!!
save (RNASeq.subset,file="./2 DATA/SUBSETS/COAD/TCGA.COAD.RNASeq.hiseq.subset.ISGS.RData")    #adjust output file names here !!!!!

