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
setwd("~/Dropbox/BREAST_QATAR")
## dependencies
required.packages <- c("corrplot")
missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(missing.packages)) install.packages(missing.packages)
library (corrplot)

#parameters
Geneset = "BCRGS"
Cancerset = "BRCA"

# load data
load ("./2 DATA/SUBSETS/BRCA/TCGA.BRCA.MA.subset.BCRGS.RData") # Select subset here !!!!!

# Corelation matrix
MA.subset.cor <- cor (MA.subset,method="pearson")

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
MA.subset.cor.sign <- cor.mtest(MA.subset.cor, 0.95)
                                

# Correlation plot
png(paste0("./4 FIGURES/CORRELATION/",Cancerset,".correlation.",Geneset,".MA.png"),res=600,height=6,width=6,unit="in") #adjust output file names here !!!!!
cex.before <- par("cex")
par(cex = 0.40)
col1 = colorRampPalette(c("blue", "white", "#009900"))
corrplot.mixed(MA.subset.cor,
               #p.mat = MA.subset.cor.sign[[1]],
               col = col1(100),
               lower = "square",
               upper ="number",
               order="FPC",
               cl.lim=c(0,1),
               tl.pos ="lt",
               tl.col = "#c00000",
               #insig="blank",
               tl.cex = 1/par("cex"),
               cl.cex = 1/par("cex"),
               title = paste0("MA Gene List (",Geneset,")"),
               cex.main = 1.4/par("cex"),
               mar=c(5.1,4.1,4.1,2.1)
               )
par(cex = cex.before)
dev.off()




