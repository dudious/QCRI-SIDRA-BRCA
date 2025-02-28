#################################################################
###
### This script normalizes ANY-CANCER cancer RNASeq Data 
### from the TCGA database
### It will process the data into a  single table. 
### Data is saved :
### ../2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/...
### File to use :
### "",Cancerset,".RNASeq.TCGA.ASSEMBLER.NORMALIZED.LOG2.RData"
###
#################################################################

# Setup environment
rm(list=ls())
setwd("~/Dropbox/BREAST_QATAR")
## dependencies
   required.packages.BioC <- c("EDASeq","base64enc","HGNChelper","RCurl","httr","stringr","digest","bitops")
   missing.packages <- required.packages.BioC[!(required.packages.BioC %in% installed.packages()[,"Package"])]
   source("http://bioconductor.org/biocLite.R")
   if(length(missing.packages)) biocLite(missing.packages)

library("EDASeq","base64enc")
source("~/Dropbox/R-projects/QCRI-SIDRA-ICR/R tools/TCGA-Assembler/Module_B.r")
source("~/Dropbox/R-projects/QCRI-SIDRA-ICR/R tools/stefanofunctions.R")
   
# Set Parameters
Cancerset <- "KIRC"
Parent.Cancerset <- substring(Cancerset,1,4)
Seq.tech = ""
if (substring(Cancerset,6,nchar(Cancerset))=="hiseq") {Seq.tech = ".hiseq"}
if (substring(Cancerset,6,nchar(Cancerset))=="GA") {Seq.tech = ".GA"}

dir.create(paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/"), showWarnings = FALSE)

# Load RAW Level 3 RNASeq Data downloaded with TCGA Assembler
RNASeq.DATA <- read.csv(paste0("./2 DATA/TCGA RNAseq/RNASeq_",Parent.Cancerset,"_ASSEMBLER/",Parent.Cancerset,".RNASeq.TCGA.ASSEMBLER",Seq.tech,".DATA.txt"),as.is=TRUE,sep="\t")
save(RNASeq.DATA,file=paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.DATA.RData")) # Backup Source Data
#load(paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.DATA.RData"))                 # Restore Source Data

# Create Gene annotaion table split column 1 in 2 (Gene Name | EntrezID)
RNASeq.DES <- as.data.frame(strsplit(RNASeq.DATA[,1], "\\|")) 
RNASeq.DES <- t(RNASeq.DES [,-1]) 
rownames(RNASeq.DES) <- NULL
colnames(RNASeq.DES) <- c("GeneSymbol","EntrezID")

# clean-up Data
RNASeq.DATA <- RNASeq.DATA[-1,-c(1,2)]                                              # drop annotaion from data
x=7
if (Cancerset == "GBM") {x=1}
if (Cancerset == "OV") {x=3}
RNASeq.DATA <- RNASeq.DATA[,which(substring (colnames (RNASeq.DATA),28,31) == x)] # remove "scaled_estimate" data 
colnames(RNASeq.DATA) <- gsub("\\.","-",colnames(RNASeq.DATA))                      # replace "." with "-" in sample names
rownames(RNASeq.DATA) <- NULL

save(RNASeq.DATA,RNASeq.DES,file=paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.CLEANED.RData")) # Backup cleaned Source Data
#load(paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.CLEANED.RData"))                            # Restore clean Source Data

# Prepare data for normalisation
length(unique(colnames(RNASeq.DATA))) - length(unique(substring(colnames(RNASeq.DATA),1,12))) # N patient with 2 samples (normal controll tissue)
Tissue <- "TP"
if (Cancerset == "SKCM"){Tissue <- c("TP","TM")}                                              # SKCM has metastatic primary tumours
  
RNASeq.DATA <- ExtractTissueSpecificSamples(inputData = RNASeq.DATA,                          # this function will also remove anotation column
                                            tissueType = Tissue,
                                            singleSampleFlag = TRUE,
                                            sampleTypeFile="~/Dropbox/R-projects/QCRI-SIDRA-ICR/R tools/TCGA-Assembler/SupportingFiles/TCGASampleType.txt"); # select primary tumour and metastatic only
RNASeq.DATA <- cbind (RNASeq.DES,RNASeq.DATA)
length(unique(colnames(RNASeq.DATA))) - length(unique(substring(colnames(RNASeq.DATA),1,12))) # 0 patient with 2 samples (normal control tissue)
colnames(RNASeq.DATA) <- substring(colnames(RNASeq.DATA),1,12)                                # rename columns from sample to patient ID
RNASeq.DATA <- RNASeq.DATA[which(RNASeq.DATA[,1]!="?"),]                                      # drop rows(genes) without approved gene-symbol
levels (RNASeq.DATA[,1]) <- c(levels (RNASeq.DATA[,1]),"SLC35E2B")                            # Fix 1 duplicate gene with updated name
RNASeq.DATA[RNASeq.DATA$EntrezID=="728661",1] <- "SLC35E2B"
row.names(RNASeq.DATA) <- RNASeq.DATA[,1]                                                     # set row.names to GeneSymbol
RNASeq.DATA <- RNASeq.DATA [,-c(1:2)]                                                         # Drop GeneSymbol, EntrezID, Hybridization REF columns
RNASeq.DATA <- as.matrix(RNASeq.DATA)
mode(RNASeq.DATA) <- "numeric"
RNASeq.DATA<-floor(RNASeq.DATA)                                                               # round off values lower integer
save(RNASeq.DATA,RNASeq.DES,file=paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.PRENORM.RData")) # Backup prenormalisation Data
#load(paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.PRENORM.RData"))                            # Restore prenormalisation Data

# Normalisation
load ("./2 DATA/geneInfo.RData")                                                # file source : QCRI
geneInfo <- as.data.frame(geneInfo)
geneInfo <- geneInfo[rownames(RNASeq.DATA),]                                    # drop the genes without RNAseq.DATA
geneInfo <- geneInfo[!is.na(geneInfo[,1]),]                                     # drop the genes without information and convert to data frame
RNASeq.DATA <- RNASeq.DATA[rownames(geneInfo),]                                 # drop the genes without information from the RNAseq.DATA
RNASeq.expr.set <- newSeqExpressionSet(RNASeq.DATA, featureData = geneInfo)     # create a new SeqExpressionSet object.
fData(RNASeq.expr.set)[, "gcContent"] <- as.numeric(geneInfo[, "gcContent"])    # make sure gcContenet is numeric
RNASeq.expr.set <- withinLaneNormalization(RNASeq.expr.set, "gcContent", which = "upper", offset = TRUE) #removes lane gene specific effects, for example effects related to gene length or GC content
RNASeq.expr.set <- betweenLaneNormalization(RNASeq.expr.set, which = "upper", offset = TRUE)             #removes effect related to in between lane distributional differences, as sequencing depth
RNASeq.NORM <-  log(RNASeq.DATA + .1) + offst(RNASeq.expr.set)                  
RNASeq.NORM <-  floor(exp(RNASeq.NORM) - .1)
#RNASeq.NORM.quantiles <- normalize.quantiles(RNASeq.NORM)                       ## Alternative function using "preprocessCore" vs "stefanofunctions.R" , Process will take very long time
RNASeq.NORM.quantiles <- t(quantileNormalization(t(RNASeq.NORM)))
RNASeq.NORM <- floor(RNASeq.NORM.quantiles)
RNASeq.NORM_Log2<-log(RNASeq.NORM+1,2)

# Save Data
save(RNASeq.NORM,file=paste0("./2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.NORMALIZED.RData"))             # without log2 transformation
save(RNASeq.NORM_Log2,file=paste0("././2 DATA/TCGA RNAseq/RNASeq_",Cancerset,"_EDASeq/",Cancerset,".RNASeq.TCGA.ASSEMBLER.NORMALIZED.LOG2.RData")) # with log2 transformation: the matrix to use

