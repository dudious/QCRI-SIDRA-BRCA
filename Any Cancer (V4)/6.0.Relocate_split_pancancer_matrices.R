


rm(list=ls())

setwd("~/Dropbox (TBI-Lab)/TCGA Analysis pipeline/")                                                                    # Setwd to location were output files have to be saved.
code_path = "~/Dropbox (Personal)/Jessica PhD Project/QCRI-SIDRA-ICR-Jessica/"                                          # Set code path to the location were the R code is located

# Set Parameters
CancerTYPES = "ALL"                                                                                                    # Specify the cancertypes that you want to download or process, c("...","...") or "ALL"
Cancer_skip = c("")                                                                                                        # If CancerTYPES = "ALL", specify here if you want to skip cancertypes
download.method = "Pancancer_matrix"                                                                                      # Specify download method (this information to be used when saving the file)
assay.platform = "gene_RNAseq" 

# Load data
TCGA.cancersets = read.csv(paste0(code_path, "Datalists/TCGA.datasets.csv"),stringsAsFactors = FALSE)                   # TCGA.datasets.csv is created from Table 1. (Cancer Types Abbreviations) 

# Create folders
dir.create("./3_DataProcessing/",showWarnings = FALSE)                                                                        # Create folder to save processed data (by Assembler module B)
dir.create(paste0("./3_DataProcessing/",download.method),showWarnings = FALSE)

# Define parameters (based on loaded data)
if (CancerTYPES == "ALL") { 
  CancerTYPES <- TCGA.cancersets$cancerType
}

N.sets = length(CancerTYPES)

i=1
for (i in 1:N.sets) {
  Cancer = CancerTYPES[i]
  if (Cancer %in% Cancer_skip) {next}
  if(!file.exists(paste0("./3_DataProcessing/TCGA_Assembler/", Cancer, "/RNASeqData/",Cancer, "_", 
                         assay.platform, "_", "normalized.Rdata"))){next}
  dir.create(paste0("./3_DataProcessing/",download.method, "/", Cancer),showWarnings = FALSE)
  dir.create(paste0("./3_DataProcessing/",download.method, "/", Cancer, "/RNASeqData"),showWarnings = FALSE)
  load(paste0("~/Dropbox (TBI-Lab)/BREAST_QATAR/2 DATA/TCGA RNAseq/RNASeq_PANCANCER/CLEAN/TCGA.", Cancer, ".RNASeq.PANCANCER.Split.RData"))
  save(clinical.matched, RNAseq.matrix, file = paste0("./3_DataProcessing/",download.method, "/", Cancer, "/RNASeqData/",
                                                      Cancer, "_gene_RNAseq_normalized_TP_filtered.Rdata"))
}

## Transform the data in the Rdata files to match the Assembler version
i=1
for(i in 2:N.sets){
  Cancer = CancerTYPES[i]
  if(Cancer == "SKCM"){
    Cancer_path = paste0 ("./3_DataProcessing/",download.method,"/",Cancer,"/RNASeqData")
    load(paste0(Cancer_path, "/", Cancer, "_gene_RNAseq_normalized_TPandTM_filtered.Rdata"))
  } else{
    if(!file.exists(paste0("./3_DataProcessing/", download.method, "/", Cancer, "/RNASeqData/", Cancer, "_gene_RNAseq_normalized_TP_filtered.Rdata"))) {next}
    Cancer_path = paste0 ("./3_DataProcessing/",download.method,"/",Cancer,"/RNASeqData")
    load(paste0(Cancer_path, "/", Cancer, "_gene_RNAseq_normalized_TP_filtered.Rdata"))
  }
 RNAseq.matrix = t(RNAseq.matrix)
 filtered.norm.RNAseqData = RNAseq.matrix
 if(Cancer == "SKCM"){
   save(filtered.norm.RNAseqData, clinical.matched, file = paste0("./3_DataProcessing/", download.method,
                                                                  "/", Cancer, "/RNASeqData/", Cancer, "_gene_RNAseq_normalized_TPandTM_filtered.Rdata"))
 } else{
   save(filtered.norm.RNAseqData, clinical.matched, file = paste0("./3_DataProcessing/", download.method, 
                                                                  "/", Cancer, "/RNASeqData/", Cancer, "_gene_RNAseq_normalized_TP_filtered.Rdata"))
 }
}
  