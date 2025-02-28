#################################################################
###
### This Script combines the clinical data relating to patients 
### that have RNASeq Data available with IMS predictions based 
### based on both RNASeq and MicroArray data.
###
#################################################################

# Setup environment
  rm(list=ls())
  ## dependencies
  ## install java for xlsx export
  ## download TCGA assembler scripts http://www.compgenome.org/TCGA-Assembler/
  required.packages <- c("xlsx","Hmisc","HGNChelper")
  missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
  if(length(missing.packages)) install.packages(missing.packages)
  library (xlsx) #xlsx needs java installed
  library (Hmisc)
  setwd("~/Dropbox/BREAST_QATAR/")

# Set Parameters
  Geneset <- "DBGS1"       # SET GENESET HERE !!!!!!!!!!!!!!
  K <- 4          
  
# Load data files 
  ClinicalData.subset <- read.csv ("./3 ANALISYS/CLINICAL DATA/TCGA.BRCA.RNASeq_subset_clinicaldata.csv")                       # Clinical data including IMS
  rownames(ClinicalData.subset) <- ClinicalData.subset$X 
  ClinicalData.subset$X <-NULL
  load (paste0("./2 DATA/SUBSETS/BRCA/TCGA.BRCA.RNASeq.subset.",Geneset,".RData"))
  CC.RNASeq <- read.csv (paste0("./3 ANALISYS/CLUSTERING/RNAseq/BRCA/BRCA.TCGA.EDASeq.k7.",
                                Geneset,".reps5000/BRCA.TCGA.EDASeq.k7.",
                                Geneset,".reps5000.k=4.consensusClass.ICR.csv"))                                                # Cluster assignment
  rownames(CC.RNASeq) <- CC.RNASeq$X 
  CC.RNASeq$X <- NULL
  colnames(CC.RNASeq) <- c("PatientID",paste0("Cluster.",Geneset,".RNSeq"))
  CC.RNASeq$PatientID <-NULL
  immunoscore <- read.csv (paste0("./3 ANALISYS/IMMUNOSCORE/immunoscore.TCGA.BRCA.",Geneset,".csv"))                            # Immunoscore
  rownames(immunoscore) <- immunoscore$X
  immunoscore$X <- NULL
  mutation.freq <- read.csv (paste0("./3 ANALISYS/Mutations/BRCA/Mutations.TCGA.BRCA.",Geneset,".Patient.by.Cluster.csv"))      # mutation frequencies
  rownames(mutation.freq) <- mutation.freq$Patient_ID
  mutation.freq <-  mutation.freq[,c("Freq.All","Freq.Missense")]
  TP53.patients <- read.csv (paste0("./3 ANALISYS/Mutations/BRCA/Mutations.TCGA.BRCA.",Geneset,".Patient.by.Cluster.csv"))      # TP53 
  rownames(TP53.patients) <- TP53.patients$Patient_ID
  TP53.patients$Patient_ID <- NULL
  TP53.patients$X <- NULL

# merge data
  Master.file <- merge (ClinicalData.subset,CC.RNASeq,by="row.names",all.x=TRUE)
  rownames(Master.file) <- Master.file$Row.names
  Master.file$Row.names <- NULL
  Master.file <- merge (Master.file,RNASeq.subset,by="row.names",all.x=TRUE)
  rownames(Master.file) <- Master.file$Row.names
  Master.file$Row.names <- NULL
  Master.file <- merge (Master.file,immunoscore,by="row.names",all.x=TRUE)
  rownames(Master.file) <- Master.file$Row.names
  Master.file$Row.names <- NULL
  Master.file <- merge (Master.file,mutation.freq,by="row.names",all.x=TRUE)
  rownames(Master.file) <- Master.file$Row.names
  Master.file$Row.names <- NULL
  Master.file <- merge (Master.file,TP53.patients,by="row.names",all.x=TRUE)
  rownames(Master.file) <- Master.file$Row.names
  Master.file$Row.names <- NULL

# export data to txt and excel
write.csv (Master.file, file = paste0("./3 ANALISYS/MASTER FILES/TCGA.BRCA.RNASeq_subset_",Geneset,".Master.csv"),row.names = TRUE);
write.xlsx (Master.file, file = paste0("./3 ANALISYS/MASTER FILES/TCGA.BRCA.RNASeq_subset_",Geneset,".Master.xlsx"), sheetName ="RNASeq ISGS.Master data", row.names=TRUE)
