#################################################################
###
### This Script PLots Heatmaps based on 
### Consensus Clustering grouping of ",Cancerset," RNASeq Data
### 
### Input data :
### ./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/...
### Data is saved :
### ./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/...
### Figures are saved :
### ./4 FIGURES/Heatmaps
###
### Parameters to modified : Geneset, K 
###
#################################################################

# Setup environment
rm(list=ls())
setwd("~/Dropbox (TBI-Lab)/BREAST_QATAR/")
#Dependencies
required.packages <- c("gplots","GMD")
missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(missing.packages)) install.packages(missing.packages)
library("gplots")

# Set Parameters
Cancerset <- "BRCA"              # SET Cancertype
BRCA.Filter <- "PCF"             # "PCF" or "BSF" Pancer or Breast specific
Geneset <- "DBGS3.FLTR"              # SET GENESET and pruclustering filter 
ALT.Geneset <- "CHKPNT_SLFN"
K <- 4                           # SET K here

# Load Data
Parent.Geneset <- substring(Geneset,1,5)
load (paste0("./2 DATA/SUBSETS/ASSEMBLER/",Cancerset,"/TCGA.",Cancerset,".RNASeq.subset.",Parent.Geneset,".for_CHKPNT_heatmap.RData"))
RNASeq.subset.ICR <- as.matrix(RNASeq.subset)
load (paste0("./2 DATA/SUBSETS/ASSEMBLER/",Cancerset,"/TCGA.",Cancerset,".RNASeq.subset.",ALT.Geneset,".for_CHKPNT_heatmap.RData"))
RNASeq.subset.ALT <- as.matrix(RNASeq.subset)

if (Cancerset == "BRCA"){
  if (substring(Geneset,7,10)=="FLTR"){
    Cancerset <- paste0(Cancerset,".",BRCA.Filter)
  }
}
Consensus.class <- read.csv(paste0("./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000.k=4.consensusClass.csv"),header=FALSE) # select source data
colnames (Consensus.class) <- c("PatientID","Group")
rownames(Consensus.class) <- Consensus.class[,1]
#load (paste0("./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/ConsensusClusterObject.Rdata"))

#Add cluster assignment to data
RNASeq.subset.ICR <- merge (RNASeq.subset.ICR,Consensus.class,by="row.names")
row.names(RNASeq.subset.ICR) <- RNASeq.subset.ICR$Row.names
RNASeq.subset.ICR$Row.names <- NULL
RNASeq.subset.ICR$PatientID <- NULL

#Rename ICR clusters
Cluster.order <- data.frame(Group=RNASeq.subset.ICR[,ncol(RNASeq.subset.ICR)], avg=rowMeans (RNASeq.subset.ICR[,1:(ncol(RNASeq.subset.ICR)-1)]))
Cluster.order <- aggregate(Cluster.order,by=list(Cluster.order$Group),FUN=mean)
Cluster.order <- cbind(Cluster.order[order(Cluster.order$avg),c(2,3)],ICR.name=c("ICR1","ICR2","ICR3","ICR4"))
Consensus.class$Group[Consensus.class$Group==Cluster.order[1,1]] <- as.character(Cluster.order[1,3])
Consensus.class$Group[Consensus.class$Group==Cluster.order[2,1]] <- as.character(Cluster.order[2,3])
Consensus.class$Group[Consensus.class$Group==Cluster.order[3,1]] <- as.character(Cluster.order[3,3])
Consensus.class$Group[Consensus.class$Group==Cluster.order[4,1]] <- as.character(Cluster.order[4,3])

#Update Cluster names
RNASeq.subset.ICR$Group <- NULL
RNASeq.subset.ICR <- merge (RNASeq.subset.ICR,Consensus.class,by="row.names")
row.names(RNASeq.subset.ICR) <- RNASeq.subset.ICR$Row.names
RNASeq.subset.ICR$Row.names <- NULL
RNASeq.subset.ICR$PatientID <- NULL

#ordering of the clusters
RNASeq.subset.ICR <- RNASeq.subset.ICR[order(factor(RNASeq.subset.ICR$Group,levels = c("ICR4","ICR3","ICR2","ICR1"))),]     
RNASeq.subset.ICR$Group <- NULL
RNASeq.subset.ALT <- RNASeq.subset.ALT[,rownames(RNASeq.subset.ICR),drop=FALSE]

#re-order the labels
Consensus.class <- Consensus.class[rownames(RNASeq.subset.ICR),]

# Heatmap 2 (simple no extra annotations)
patientcolors <- Consensus.class
levels (patientcolors$Group) <- c(levels (patientcolors$Group),c("#FF0000","#FFA500","#00FF00","#0000FF"))  #Aply color scheme to patients
patientcolors$Group[patientcolors$Group=="ICR4"] <- "#FF0000"
patientcolors$Group[patientcolors$Group=="ICR3"] <- "#FFA500"
patientcolors$Group[patientcolors$Group=="ICR2"] <- "#00FF00"
patientcolors$Group[patientcolors$Group=="ICR1"] <- "#0000FF"
#patientcolors$Group <- droplevels(patientcolors$Group)
patientcolors <- patientcolors$Group
my.palette <- colorRampPalette(c("blue", "yellow", "red"))(n = 297)
my.colors = unique(c(seq(-4,-0.5,length=100),seq(-0.5,1,length=100),seq(1,4,length=100)))
png(paste0("./4 FIGURES/Heatmaps/Heatmap.RNASeq.TCGA.",Cancerset,".",Geneset,".CHKPNT_heatmap_ICR.png"),res=600,height=6,width=6,unit="in")     # set filename
heatmap.2(t(RNASeq.subset.ICR),
          main = paste0("Heatmap RNASeq - ",Parent.Geneset," sel., K=",K),
          col=my.palette,                   #set color sheme RED High, GREEN low
          breaks=my.colors,                                 
          ColSideColors=patientcolors,      #set goup colors                 
          key=TRUE,
          symm=FALSE,
          symkey=FALSE,
          symbreaks=TRUE,             
          scale="row",
          density.info="none",
          trace="none",
          labCol=FALSE,
          cexRow=1.3,cexCol=0.1,margins=c(2,7),
          Colv=FALSE)
par(lend = 1)
legend("topright",legend = c("ICR4","ICR3","ICR2","ICR1"),
       col = c("red","orange","green","blue"),lty= 1,lwd = 5,cex = 0.7)
dev.off()

#split ACT/INH

inhibiting.DBGS3.genes <- c("PDCD1","CTLA4","CD274","FOXP3","IDO1")
RNASeq.subset.ICR.INH <- RNASeq.subset.ICR[,inhibiting.DBGS3.genes]
RNASeq.subset.ICR.ACT <- RNASeq.subset.ICR[,-which(colnames(RNASeq.subset.ICR) %in% inhibiting.DBGS3.genes)]


png(paste0("./4 FIGURES/Heatmaps/Heatmap.RNASeq.TCGA.",Cancerset,".",Geneset,".CHKPNT_heatmap_ICR.ACT.png"),res=600,height=6,width=6,unit="in")     # set filename
heatmap.2(t(RNASeq.subset.ICR.ACT),
          main = paste0("Heatmap RNASeq - ",Parent.Geneset," sel., K=",K),
          col=my.palette,                   #set color sheme RED High, GREEN low
          breaks=my.colors,                                 
          ColSideColors=patientcolors,      #set goup colors                 
          key=TRUE,
          symm=FALSE,
          symkey=FALSE,
          symbreaks=TRUE,             
          scale="row",
          density.info="none",
          trace="none",
          labCol=FALSE,
          cexRow=1.3,cexCol=0.1,margins=c(2,7),
          Colv=FALSE)
par(lend = 1)
legend("topright",legend = c("ICR4","ICR3","ICR2","ICR1"),
       col = c("red","orange","green","blue"),lty= 1,lwd = 5,cex = 0.7)
dev.off()

#png(paste0("./4 FIGURES/Heatmaps/Heatmap.RNASeq.TCGA.",Cancerset,".",Geneset,".CHKPNT_heatmap_ICR.INH.png"),res=600,height=4,width=6,unit="in")     # set filename
dev.new()
heatmap.2(t(RNASeq.subset.ICR.INH),
          main = paste0("Heatmap RNASeq - ",Parent.Geneset," sel., K=",K),
          col=my.palette,                   #set color sheme RED High, GREEN low
          breaks=my.colors,                                 
          ColSideColors=patientcolors,      #set goup colors                 
          key=TRUE,
          symm=FALSE,
          symkey=FALSE,
          symbreaks=TRUE,             
          scale="row",
          density.info="none",
          trace="none",
          labCol=FALSE,
          cexRow=1.3,cexCol=0.1,margins=c(2,7),
          Colv=FALSE)
par(lend = 1)
legend("topright",legend = c("ICR4","ICR3","ICR2","ICR1"),
       col = c("red","orange","green","blue"),lty= 1,lwd = 5,cex = 0.7)
dev.off()


#extra checkpoint genes
x=cbind(t(RNASeq.subset.ALT),t(RNASeq.subset.ALT))
png(paste0("./4 FIGURES/Heatmaps/Heatmap.RNASeq.TCGA.",Cancerset,".",Geneset,".",ALT.Geneset,"_heatmap_ALT.png"),res=600,height=6,width=6,unit="in")     # set filename
heatmap.2(t(x),
          main = paste0("Heatmap RNASeq - ",Parent.Geneset," sel., K=",K),
          col=my.palette,                   #set color sheme RED High, GREEN low
          breaks=my.colors,                                 
          ColSideColors=patientcolors,      #set goup colors                 
          key=TRUE,
          symm=FALSE,
          symkey=FALSE,
          symbreaks=TRUE,             
          scale="row",
          density.info="none",
          trace="none",
          labCol=FALSE,
          cexRow=1.3,cexCol=0.1,margins=c(2,7),
          Colv=FALSE)
par(lend = 1)
legend("topright",legend = c("ICR4","ICR3","ICR2","ICR1"),
       col = c("red","orange","green","blue"),lty= 1,lwd = 5,cex = 0.7)
dev.off()

