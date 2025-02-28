#########################
## Script to perform mutation frequency boxplot and specific gene barplot
## Input: Mutation .maf file, and the cluster assignment file (sample name, cluster assignment)
## Modify: Cancer Type (cancer)
##         Number of clusters (num.clusters)
##         Paths to mutation file, cluster assignment file, and output filename
## 
######


## Setup environment
rm(list=ls())
setwd("~/Dropbox/BREAST_QATAR/")
#Dependencies
required.packages <- c("ggplot2", "plyr")
missing.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(missing.packages)) install.packages(missing.packages)
library("ggplot2")
library("plyr")

## Parameters
Cancerset <- "BRCA.BSF2"     # FOR BRCA use BRCA.PCF or BRCA.BSF ,Dont use -GA or -hiseq
Geneset = "DBGS3.FLTR"  # SET GENESET HERE !!!!!!!!!!!!!!
K = 4                   # SET K here
Plot.type = "NonSilent" # Alterantives "All" , "Any" , "Missense", "NonSilent"
IMS.filter = "Luminal"      # Alterantives "All" , "Luminal" , "Basal", "Her2"
stats = "stats"              # Alterantives : "stats" ""

## Ines RNASeq Clustering k = 4
num.clusters = 4
clusters = rep(paste0("ICR", 1:num.clusters))

## Read the mutation frequency file 
load (paste0("./3 ANALISYS/Mutations/",Cancerset,"/Mutation.Data.TCGA.",Cancerset,".",Geneset,".Frequencies.RDATA"))
#clinical data
ClinicalData.subset <- read.csv (paste0("./3 ANALISYS/CLINICAL DATA/TCGA.",Cancerset,".RNASeq_subset_clinicaldata.csv"))                       # Clinical data including IMS
rownames(ClinicalData.subset) <- ClinicalData.subset$X 
ClinicalData.subset$X <-NULL
#MAPK MUTSTAT
Mutstat<-read.csv("./3 ANALISYS/DIFFERENTIAL EXPRESSION/15Oct/MAPKs/FinalClassification.csv")

#add subtype to Mutation.Frequency.Patient Table
Mutation.Frequency.Patient$Subtype <- ClinicalData.subset$TCGA.PAM50.RMethod.RNASeq[match(Mutation.Frequency.Patient$Patient_ID,rownames(ClinicalData.subset))]

#add MUTSTAT to Mutation.Frequency.Patient Table
Mutation.Frequency.Patient$Mutstat <- Mutstat$MAP2K4.MAP3K1[match(Mutation.Frequency.Patient$Patient_ID,Mutstat$Sample)]

#Filer  Mutation.Frequency.Patient Table by IMS
if (IMS.filter == "Luminal") {
  Mutation.Frequency.Patient <- Mutation.Frequency.Patient[Mutation.Frequency.Patient$Subtype %in% c("Luminal A","Luminal B"),]
} else if (IMS.filter == "Basal"){
  Mutation.Frequency.Patient <- Mutation.Frequency.Patient[Mutation.Frequency.Patient$Subtype %in% c("Basal-like"),]
} else if (IMS.filter == "Her2"){
  Mutation.Frequency.Patient <- Mutation.Frequency.Patient[Mutation.Frequency.Patient$Subtype %in% c("HER2-enriched"),]
}

#Prepare Data for Boxplots
numMuts.All           = data.frame(count=Mutation.Frequency.Patient$Freq.All          ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "All")
numMuts.Missense      = data.frame(count=Mutation.Frequency.Patient$Freq.Missense     ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Missense")
numMuts.Nonsense      = data.frame(count=Mutation.Frequency.Patient$Freq.Nonsense     ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Nonsense")
numMuts.Silent        = data.frame(count=Mutation.Frequency.Patient$Freq.Silent       ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Silent")
numMuts.Other         = data.frame(count=Mutation.Frequency.Patient$Freq.Other        ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Other")
numMuts.NonSilent     = data.frame(count=Mutation.Frequency.Patient$Freq.NonSilent    ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "NonSilent")
numMuts.Silent        = data.frame(count=Mutation.Frequency.Patient$Freq.Silent       ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Silent")
numMuts.Any           = data.frame(count=Mutation.Frequency.Patient$Freq.Any          ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Any")
numMuts.Missense.Any  = data.frame(count=Mutation.Frequency.Patient$Freq.Missense.Any ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Missense.Any")
numMuts.Silent.Any    = data.frame(count=Mutation.Frequency.Patient$Freq.Silent.Any   ,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "Silent.Any")
numMuts.NonSilent.Any = data.frame(count=Mutation.Frequency.Patient$Freq.NonSilent.Any,Mutstat=Mutation.Frequency.Patient$Mutstat,mut.type = "NonSilent.Any")


# statistics
#ANOVA
test.All.aov    = aov(count~Mutstat,data=numMuts.All)
p.value.All.aov = summary(test.All.aov)[[1]][["Pr(>F)"]][[1]]
test.Missense.aov    = aov(count~Mutstat,data=numMuts.Missense)
p.value.Missense.aov = summary(test.Missense.aov)[[1]][["Pr(>F)"]][[1]]
test.Silent.aov    = aov(count~Mutstat,data=numMuts.Silent)
p.value.Silent.aov = summary(test.Silent.aov)[[1]][["Pr(>F)"]][[1]]
test.Nonsense.aov    = aov(count~Mutstat,data=numMuts.Nonsense)
p.value.Nonsense.aov = summary(test.Nonsense.aov)[[1]][["Pr(>F)"]][[1]]
test.Other.aov    = aov(count~Mutstat,data=numMuts.Other)
p.value.Other.aov = summary(test.Other.aov)[[1]][["Pr(>F)"]][[1]]
test.Any.aov    = aov(count~Mutstat,data=numMuts.Any)
p.value.Any.aov = summary(test.Any.aov)[[1]][["Pr(>F)"]][[1]]
test.Missense.Any.aov    = aov(count~Mutstat,data=numMuts.Missense.Any)
p.value.Missense.Any.aov = summary(test.Missense.Any.aov)[[1]][["Pr(>F)"]][[1]]
test.Silent.Any.aov    = aov(count~Mutstat,data=numMuts.Silent.Any)
p.value.Silent.Any.aov = summary(test.Silent.Any.aov)[[1]][["Pr(>F)"]][[1]]
test.NonSilent.aov    = aov(count~Mutstat,data=numMuts.NonSilent)
p.value.NonSilent.aov    = summary(test.NonSilent.aov)[[1]][["Pr(>F)"]][[1]]
test.NonSilent.Any.aov    = aov(count~Mutstat,data=numMuts.NonSilent.Any)
p.value.NonSilent.Any.aov    = summary(test.NonSilent.Any.aov)[[1]][["Pr(>F)"]][[1]]

p.values.aov <- data.frame(mut.type=c("All","Missense","Silent","Nonsense","Other","NonSilent","Any","Missense.Any","Silent.Any","NonSilent.Any"),
                           p.value=c(p.value.All.aov,p.value.Missense.aov,p.value.Silent.aov,p.value.Nonsense.aov,p.value.Other.aov,
                                     p.value.NonSilent.aov,p.value.Any.aov,p.value.Missense.Any.aov,p.value.Silent.Any.aov,p.value.NonSilent.Any.aov))
p.values.aov$p.value <-signif(p.values.aov$p.value,digits=3)

#Kruskal-wallis
test.All.kruskal    = kruskal.test(count~Mutstat,data=numMuts.All)
test.Missense.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Missense)
test.Silent.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Silent)
test.Nonsense.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Nonsense)
test.Other.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Other)
test.Any.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Any)
test.Missense.Any.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Missense.Any)
test.Silent.Any.kruskal    = kruskal.test(count~Mutstat,data=numMuts.Silent.Any)
test.NonSilent.kruskal    = kruskal.test(count~Mutstat,data=numMuts.NonSilent)
test.NonSilent.Any.kruskal    = kruskal.test(count~Mutstat,data=numMuts.NonSilent.Any)

p.values.kruskal <- data.frame(mut.type=c("All","Missense","Silent","Nonsense","Other","NonSilent","Any","Missense.Any","Silent.Any","NonSilent.Any"),
                               p.value=c(test.All.kruskal$p.value,
                                         test.Missense.kruskal$p.value,
                                         test.Silent.kruskal$p.value,
                                         test.Nonsense.kruskal$p.value,
                                         test.Other.kruskal$p.value,
                                         test.NonSilent.kruskal$p.value,
                                         test.Any.kruskal$p.value,
                                         test.Missense.Any.kruskal$p.value,
                                         test.Silent.Any.kruskal$p.value,
                                         test.NonSilent.Any.kruskal$p.value))
p.values.kruskal$p.value <-signif(p.values.kruskal$p.value,digits=3)

# Combine
numMuts.All.combo    = rbind(numMuts.All,numMuts.Missense,numMuts.Silent,numMuts.Nonsense,numMuts.Other)
rownames(numMuts.All.combo) = NULL
colnames(numMuts.All.combo) = c( "count", "Mutstat", "mut.type")

numMuts.Any.combo    = rbind(numMuts.All,numMuts.Any,numMuts.Missense,numMuts.Missense.Any,numMuts.Silent,numMuts.Silent.Any )
rownames(numMuts.Any.combo) = NULL
colnames(numMuts.Any.combo) = c( "count", "Mutstat", "mut.type")

numMuts.Silent.combo = rbind(numMuts.All,numMuts.Silent,numMuts.NonSilent,numMuts.Any,numMuts.Silent.Any,numMuts.NonSilent.Any )
rownames(numMuts.Silent.combo) = NULL
colnames(numMuts.Silent.combo) = c( "count", "Mutstat", "mut.type")

#Pick the one to blot
if (Plot.type =='All') {
  numMuts.blot = numMuts.All.combo
  blot.width = 1500
  blot.font.size = 25
  } else if (Plot.type =='Any') {
  numMuts.blot = numMuts.Any.combo
  blot.width = 1500
  blot.font.size = 25
  } else if (Plot.type =='Missense') {
  numMuts.blot = numMuts.Missense
  blot.width = 450
  blot.font.size = 13
  } else if (Plot.type =='NonSilent') {
  numMuts.blot = numMuts.Silent.combo
  blot.width = 1500
  blot.font.size = 25
}
numMuts.blot = numMuts.blot[complete.cases(numMuts.blot),]
meds = ddply(numMuts.blot, .(mut.type, Mutstat), summarise, med = median(count)) ## median

meds$p.value.aov = p.values.aov$p.value [match(meds$mut.type,p.values.aov$mut.type)]
meds$p.value.aov.label = paste0("p = ",meds$p.value.aov) 
meds[meds$subtype != "Luminal B","p.value.aov.label"] = ""

meds$p.value.kruskal = p.values.kruskal$p.value [match(meds$mut.type,p.values.kruskal$mut.type)]
meds$p.value.kruskal.label = paste0("p = ",meds$p.value.kruskal) 
meds[meds$subtype != "Luminal B","p.value.kruskal.label"] = ""

meds.limit = 250
if (Cancerset == "COAD"){meds.limit = 6*max(meds$med)}
mean.n = function(x){ return(c(y = 0 , label = round(mean(x),1))) } ## mean

#png(paste0("./4 FIGURES/Mutation Plots/Mutations.TCGA.",Cancerset,".",Geneset,".",Plot.type,".",IMS.filter,".",stats,".IMSONLY.png"), height = 1000, width= blot.width)   #set filename
dev.new()
Mutstat.order = c("WT", "MUT")
colors = c("#daa520","#da70d6","#eaff00","#00c0ff","#d3d3d3")
gg = ggplot(numMuts.blot, aes(Mutstat, count, fill=Mutstat)) +
  stat_boxplot(geom ='errorbar') +
  geom_boxplot(notch=TRUE) +
  geom_jitter(position=position_jitter(width=0.2,height=0.1))
#, aes(color="lightgray")) 
gg = gg + ylab("Number of mutations per sample") +
  scale_x_discrete(limits=Mutstat.order) +
  facet_grid(.~mut.type,
             scales = "free",
             space="free") +
  xlab("MAP3K1 or MAP2K4 Mutation") + theme_bw() 
gg = gg + scale_fill_manual(values = colors) +
  scale_y_continuous(breaks = seq(0, meds.limit, 100)) +
  coord_cartesian(ylim=c(-15, 250)) 
gg = gg + theme(strip.text.x = element_text(size = 20, colour = "black"),
                legend.position = "none",
                axis.text.x = element_text(size = 12, vjust=1,angle = 90),
                axis.title.x = element_text(size = 18, vjust = -1),
                axis.text.y = element_text(size = 18, vjust=1),
                axis.title.y = element_text(size = 18, vjust = 1))
gg = gg + geom_text(data = meds,
                    aes(y = 0, label = round(med,2)),
                    size = 4, vjust = 1.2)
gg = gg + stat_summary(fun.data = mean.n,
                       geom = "text",
                       fun.y = mean,
                       colour = "black",
                       vjust = 3.7,
                       size = 4)
if (stats == "stats") {
  gg = gg + geom_text(data = meds,
                      aes(y = meds.limit, label = p.value.aov.label),
                      size = 7, vjust = 1.2) +
    geom_text(data = meds,
              aes(y = meds.limit-10, label = p.value.kruskal.label),
              size = 7, vjust = 1.2)
}
gg = gg + ggtitle(paste0("Mutations.TCGA.",Cancerset,".",Geneset,".",Plot.type,".",IMS.filter)) +
          theme(plot.title = element_text(size = blot.font.size, lineheight=5, face="bold"))

print(gg)
#dev.off()
