
#################################################
## Creates the (Sample by Gene) Mutation Matrix
##    
## Input: 
## ./2 DATA/TCGA Mutations/",Cancerset,"/Somatic_Mutations/",Cancerset,".TCGA.combined.Mutation.Data.maf.Rdata
## ./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000.k=4.consensusClass.ICR.csv
##
## Output: Table (Row = Sample Name, Column = Gene, Cell = NA/Cluster)
## 
## Modify: Cancerset, Geneset
## Author: SA,WHX
#####################################

# Setup environment
rm(list=ls())
#setwd("~/Dropbox/BREAST_QATAR/")
setwd("f:/DropBox Wouter/Dropbox (TBI-Lab)/BREAST_QATAR/")
# Dependencies
required.packages <- c("beepr")
missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(missing.packages)) install.packages(missing.packages)
library("beepr")

## Parameters
Cancerset      = "BRCA"
Geneset        = "DBGS3.FLTR"
BRCA.Filter    = "PCF"
matrix.type    = "NonSilent"         # Alterantives "Any" , "Missense", "NonSilent"
IMS.filter     = "All"           # Alterantives "All" , "Luminal" , "Basal", "Her2" ,"LumA" ,"LumB"
selected.genes = c("TP53","MAP2K4","MAP3K1","CTCF","FCGBP")

##load data
## Read the mutation .maf file and cluster assignments
if (Cancerset %in% c("COAD","READ","UCEC")) {
  #GA data
  Cancerset <- paste0(Cancerset,"-GA")
  load (paste0("./2 DATA/TCGA Mutations/",Cancerset,"/Somatic_Mutations/",Cancerset,".TCGA.combined.Mutation.Data.maf.Rdata"))
  maf.merged.table.GA <- maf.merged.table
  Consensus.class.GA <- read.csv(paste0("./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000.k=4.consensusClass.ICR.csv"),header=TRUE) # select source data
  Consensus.class.GA <- Consensus.class.GA[,-1]
  colnames (Consensus.class.GA) <- c("Patient_ID","Cluster")
  rownames(Consensus.class.GA) <- Consensus.class.GA[,1]
  rm(maf.merged.table)
  Cancerset <- substring(Cancerset,1,4)
  #hiseq data
  Cancerset <- paste0(Cancerset,"-hiseq")
  load (paste0("./2 DATA/TCGA Mutations/",Cancerset,"/Somatic_Mutations/",Cancerset,".TCGA.combined.Mutation.Data.maf.Rdata"))
  maf.merged.table.hiseq <- maf.merged.table 
  Consensus.class.hiseq <- read.csv(paste0("./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000.k=4.consensusClass.ICR.csv"),header=TRUE) # select source data
  Consensus.class.hiseq <- Consensus.class.hiseq[,-1]
  colnames (Consensus.class.hiseq) <- c("Patient_ID","Cluster")
  rownames(Consensus.class.hiseq) <- Consensus.class.hiseq[,1]
  rm(maf.merged.table)
  Cancerset <- substring(Cancerset,1,4)
  #merge GA-hiseq
  Consensus.class <- unique(rbind (Consensus.class.hiseq,Consensus.class.GA))
  maf.merged.table   <- unique(rbind (maf.merged.table.hiseq,maf.merged.table.GA))
} else {
  load (paste0("./2 DATA/TCGA Mutations/",Cancerset,"/Somatic_Mutations/",Cancerset,".TCGA.combined.Mutation.Data.maf.Rdata"))
  if (Cancerset == "BRCA"){
    if (substring(Geneset,7,10)=="FLTR"){
      Cancerset <- paste0(Cancerset,".",BRCA.Filter)
    }
  }
  Consensus.class = read.csv(paste0("./3 ANALISYS/CLUSTERING/RNAseq/",Cancerset,"/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000/",Cancerset,".TCGA.EDASeq.k7.",Geneset,".reps5000.k=4.consensusClass.ICR.csv"),header=TRUE) # select source data
  Consensus.class = Consensus.class[,-1]
  colnames (Consensus.class) = c("Patient_ID","Cluster")
  rownames(Consensus.class) = Consensus.class[,1]
} 
muts = maf.merged.table
rm(maf.merged.table)
muts$sample.name = substr(muts$Tumor_Sample_Barcode, 1, 12)
cluster.assignment = Consensus.class[which(rownames(Consensus.class) %in% muts$sample.name),] # drop samples without any mutation data  

## Merge the cluster info and Remove the mutations with samples not having cluster information
muts$cluster = cluster.assignment$Cluster[match(muts$sample.name, as.character(cluster.assignment$Patient_ID))]
muts =  (muts[-which(is.na(muts$cluster)), ])

## Pick the Missense Mutations only
if (matrix.type =="Missense") {muts = muts[which(muts$Variant_Classification=="Missense_Mutation"), ]}

## Pick the NonSilent Mutations only
if (matrix.type =="NonSilent") {muts = muts[which(muts$Variant_Classification!="Silent"), ]}

## Get the unique list of genes and samples
all.genes = unique(as.character(muts$Hugo_Symbol))
all.samples = unique(substr(muts$Tumor_Sample_Barcode, 1, 12))

## Create the table with col = genes and row = samples
genes.mutations = data.frame(matrix(ncol=length(all.genes), nrow=length(all.samples)))
rownames(genes.mutations) = all.samples
colnames(genes.mutations) = all.genes

## Fill the table
for(i in 1:nrow(muts)){
  sample.name = as.character(muts$sample.name[i])
  gene = as.character(muts$Hugo_Symbol[i])
  genes.mutations[sample.name,gene] = 1
  #genes.mutations[sample,gene] =  cluster.assignment$cluster[which(cluster.assignment$sample.name==sample.name)]
}
save (genes.mutations,
      file=paste0("./3 ANALISYS/Mutations/",Cancerset,"/",Cancerset,".",IMS.filter,".",Geneset,".Mutation.Matrixes.",matrix.type,".Rdata"))





