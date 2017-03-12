#!/usr/binenv Rscript

# A command-line interface to WGCNA for calculating connectivity from expression data

# setup R error handline to go to stderr
options(show.error.messages=FALSE,
        error=function(){
          cat(geterrmessage(), file=stderr())
          quit("no", 1, F)
        })

# we need that to not crash galaxy with an UTF8 error on German LC settings.
loc = Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")

# suppress warning
options(warn = -1)

suppressPackageStartupMessages({
  library(getopt)
  library(tools)
})

options(stringsAsFactors=FALSE, useFancyQuotes=FALSE)
args = commandArgs(trailingOnly=TRUE)

# column 1: the long flag name
# column 2: the short flag alias. A SINGLE character string
# column 3: argument mask
#           0: no argument
#           1: argument required
#           2: argument is optional
# column 4: date type to which the flag's argument shall be cast.
#           possible values: logical, integer, double, complex, character.
spec_list=list()
spec_list$threads = c('threads', '-t', '2', 'integer')
spec_list$expressionData = c('expressionData', 'f', '1', 'character')
spec_list$maxBeta = c('maxBeta', 'b', 1, 'integer')
spec_list$rPowerTableOutput = c('rPowerTableOutput', 'r', 1, 'character')
spec_list$softConnectivityOutput = c('softConnectivityOutput', 's', 1, 'character')
spec_list$kMostConnectedGenes = c('kMostConnectedGenes', 'k', 1, 'integer')
spec_list$hclustMethod = c('hclustMethod', 'h', 1, 'character')
spec_list$cutHeight = c('cutHeight', 'c', 1, 'double')
spec_list$minSize = c('minSize', 'm', 1, 'integer')
spec_list$plotColorUnderTree = c('plotColorUnderTree', 'u', 1, 'logical')
spec_list$dendrogramOutput = c('dendrogramOutput', 'd', 1, 'character')
spec_list$kNetworkGenes = c('kNetworkGenes', 'n', 1, 'integer')
spec_list$networkPlot = c('networkPlot', 'p', 1, 'character')

spec = t(as.data.frame(spec_list))

opt = getopt(spec)
# arguments are accessed by long flag name (the first column in the spec matrix)
#                        NOT by element name in the spec_list
# example: opt$help, opt$expression_file

suppressPackageStartupMessages({
  library(MASS)
  library(ggplot2)
  library(ggdendro)
  library(class)
  library(cluster)
  library(impute)
  library(Hmisc)
  library(WGCNA)
})

# allow multi-threads for WGCNA
if(!is.null(opt$threads)){
  allowWGCNAThreads(nThreads = opt$threads)
}
# disableWGCNAThreads()


#===import data===
expData = read.csv(opt$expressionData, header = TRUE, row.names = 1)

#===soft threshold (beta)===
# calculate R power table and write data into csv file
powers = seq(1, opt$maxBeta)
RpowerTable = pickSoftThreshold(expData, powerVector = powers)[[2]]
write.csv(RpowerTable, file=opt$rPowerTableOutput)

# plot scale free fit R square versus different soft threshold beta
#   (wrap plotting code into a function)
scfRSqPlot = function(){
  plot(RpowerTable[,1], -sign(RpowerTable[,3])*RpowerTable[,2],
       xlab=" Soft Threshold (power)",
       ylab=expression("Scale Free Topology Model Fit, Signed "~R^2), type="n")
  text(RpowerTable[,1], -sign(RpowerTable[,3])*RpowerTable[,2],
       labels=powers,cex=0.7,col="red")
  abline(h=0.95,col="red")
}

# plot mean connectivity versus different soft threshold beta
#    (wrap plotting code into a function)
connectivityPlot = function(){
  plot(RpowerTable[,1], RpowerTable[,5],
       xlab="Soft Threshold (power)",
       ylab="Mean Connectivity", type="n")
  text(RpowerTable[,1], RpowerTable[,5],
       labels=powers, cex=0.7,col="red")
}


# calculate optimal beta
for(i in powers){
  row = subset(RpowerTable, Power == i)
  if(row$SFT.R.sq >= 0.95){
    optimBeta = row[1,1]
    break
  }
}

#===calculate soft connectivity and write result into csv file===
gene_id = colnames(expData)
softConn = softConnectivity(expData, power = optimBeta)
dfConn = data.frame(gene_id = gene_id, connectivity = softConn)
dfConn = dfConn[order(dfConn$connectivity, decreasing=TRUE), ]
write.csv(dfConn, file=opt$softConnectivityOutput, row.names = FALSE)

#===get k number of the most connected genes===
kRank = rank(-softConn)
k_selected = kRank <= opt$kMostConnectedGenes
subKExpData = expData[, k_selected]

#===calculate adjacency===
ADJ_data = adjacency(subKExpData, power = optimBeta)
# dissimilarity matrix
diss_TOM_data = TOMdist(ADJ_data)
# hierachical clustering
hier_TOM_data = hclust(as.dist(diss_TOM_data), method=opt$hclustMethod)
# cluster detection by a constant height cut
clusterColors = cutreeStaticColor(hier_TOM_data, cutHeight = opt$cutHeight, minSize = opt$minSize)

#===plot dendrogram===
# plot color under tree, yes or no?
pdf(file=opt$dendrogramOutput, paper="a4")
# par(mfrow=c(1,2))
layout(matrix(c(1,2,3,3,4,4), 3,2, byrow = T))
scfRSqPlot()
connectivityPlot()
if(opt$plotColorUnderTree){
  mainText = paste0('Dendrogram', opt$kMostConnectedGenes, ' most connected genes')
  plot(hier_TOM_data, labels=F, main="")
  plotColorUnderTree(hier_TOM_data, colors=data.frame(module=clusterColors))
} else {
  par(mfrow=c(1,1))
  plot(hier_TOM_data, labels=F, main="")
}
dev.off()

#====network plot===
pdf(file=opt$networkPlot)
kRank = rank(-softConn)
k_selected = kRank <= opt$kNetworkGenes
subKExpData = expData[, k_selected]
ADJ_network = adjacency(subKExpData, power = optimBeta)

library(igraph)
library(netbiov)
g = graph.adjacency(ADJ_network, mode='undirected', weighted = TRUE, diag = FALSE)
data('color_list')
plot.modules(g, layout.function = c(layout.fruchterman.reingold,
                                    layout.star,layout.reingold.tilford, layout.graphopt,layout.kamada.kawai),
             modules.color = sample(color.list$bright), sf=40, tkplot=FALSE)
id <- plot.abstract.nodes(g, layout.function = c(layout.fruchterman.reingold),
                          nodes.color = sample(color.list$bright),
                          sf=40, tkplot=FALSE)
xx <- plot.abstract.nodes(g, nodes.color ="grey",layout.function=layout.star,
                          edge.colors= sample(color.list$bright), tkplot =FALSE,lab.color = "red")
splitg.mst(g, vertex.color = sample(color.list$bright), tkplot = FALSE)
dev.off()

