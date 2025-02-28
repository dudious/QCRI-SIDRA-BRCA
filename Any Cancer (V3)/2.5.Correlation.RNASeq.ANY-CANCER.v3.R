#################################################################
###
### This script creates a correlation matrix for the selcted genes
### Data used:
### ./2 DATA/SUBSETS/...
### Output :
### ./4 FIGURES/...
###
#################################################################

# Setup environment
rm(list=ls())
#setwd("~/Dropbox/BREAST_QATAR")
#setwd("/mnt3/wouter/BREAST-QATAR/")
setwd("~/Dropbox (TBI-Lab)/BREAST_QATAR")
## dependencies
required.packages <- c("corrplot")
missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(missing.packages)) install.packages(missing.packages)
library (corrplot)

# Set Parameters
DL.Method    = "ASSEMBLER" #Choose "ASSEMBLER" or "BIOLINKS"
sample.types = "TP" #Alternatives TP , TP_TM , Selected
Cancersets   = "BRCA"     # Select the Cancer to use
Geneset      = "DBGS3"    # Select the genset to use
Filter       = "TRUE"     # Use Pre-Clustering Filter "TRUE" OR "FALSE"  (setup filter in "2.3.Exclude.Clinical" script)
BRCA.Filter  = "BSF2"      # "PCF" or "BSF" Pancer or Breast specific
test         = "pearson"
colpatern    = colorRampPalette(c("blue", "black", "green"))

# DO ALL
TCGA.cancersets <- read.csv ("./2 DATA/TCGA.datasets.csv")
if (Cancersets == "ALL") { 
  Cancersets = gsub("\\]","",gsub(".*\\[","",TCGA.cancersets$Cancername))
}
N.sets = length(Cancersets)
for (i in 1:N.sets) {
  Cancerset = Cancersets[i]
  if (Cancerset %in% c("LAML","FPPP")) {next}
  Parent.Cancerset <- substring(Cancerset,1,4)

# load data
#load ("./2 DATA/SUBSETS/METABRIC/METABRIC.RNASEQ.DATA.1.genesubset.25G.DB.RData") # Select subset here !!!!!
#load ("./2 DATA/SUBSETS/METABRIC/METABRIC.RNASEQ.DATA.2.genesubset.25G.DB.RData") # Select subset here !!!!!
#RNASEQ.DATA.ALL.subset <- rbind(RNASEQ.DATA.1.subset,RNASEQ.DATA.2.subset)
load (paste0("./2 DATA/SUBSETS/",DL.Method,"/",Cancerset,"/TCGA.",Cancerset,".RNASeq.",sample.types,".subset.",Geneset,".RData")) # Select subset here !!!!!

# Corelation matrix
RNASeq.subset.cor <- cor (RNASeq.subset,method=test)

# cor significance
cor.mtest <- function(mat, conf.level = 0.95) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat <- lowCI.mat <- uppCI.mat <- matrix(NA, n, n)
  diag(p.mat) <- 0
  diag(lowCI.mat) <- diag(uppCI.mat) <- 1
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], conf.level = conf.level)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
      lowCI.mat[i, j] <- lowCI.mat[j, i] <- tmp$conf.int[1]
      uppCI.mat[i, j] <- uppCI.mat[j, i] <- tmp$conf.int[2]
    }
  }
  return(list(p.mat, lowCI.mat, uppCI.mat))
}
RNASeq.subset.cor.sign <- cor.mtest(RNASeq.subset.cor, 0.95)

# Correlation plot
png(paste0("./4 FIGURES/CORRELATION/",Geneset,"/",DL.Method,".",sample.types,".RNAseq.",test,".correlation.",Cancerset,".",Geneset,".png"),res=600,height=6,width=6,unit="in")  #adjust output file names here !!!!!
#dev.new()
cex.before <- par("cex")
par(cex = 0.45)
col1 = colpatern
lims=c(-1,1)
if (length(RNASeq.subset.cor[RNASeq.subset.cor<0]) == 0) {lims=c(0,1)} 
corrplot.mixed (RNASeq.subset.cor,
               #type="lower",
               #p.mat = RNASeq.subset.cor.sign[[1]],    # add significance to correlations
               col = col1(100),
               lower = "square",
               upper ="number",
               order="FPC",
               cl.lim=lims,                      # only positive correlations
               tl.pos ="lt",
               tl.col = "#c00000",
               #insig="pch",                          # remove insignificant correlations
               tl.cex = 1/par("cex"),
               cl.cex = 1/par("cex"),
               title = paste0(test," TCGA-RNASeq (",Cancerset,".",Geneset," avg:",round(mean(RNASeq.subset.cor),2)," N:",nrow(RNASeq.subset),")"),
               cex.main = 1/par("cex"),
               mar=c(5.1,4.1,4.1,2.1))
par(cex = cex.before)
dev.off()

print(paste0(Cancerset," done"))
nrow(RNASeq.subset)
}
