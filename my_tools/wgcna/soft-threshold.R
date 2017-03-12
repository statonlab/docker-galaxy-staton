#!/usr/binenv Rscript

# A command-line interface to WGCNA for use with galaxy


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
spec_list$help = c('help', 'h', '0', 'logical')
spec_list$threads = c('threads', '-t', '2', 'integer')
spec_list$expressionData = c('expressionData', 'f', '1', 'character')
spec_list$betaMaximum = c('betaMaximum', 'b', 1, 'integer')
spec_list$rPowerTableOutput = c('rPowerTableOutput', 'r', 1, 'character')
spec_list$scaleFreeFitPlot = c('scaleFreeFitPlot', 'p', 1, 'character')
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

# read expression data
#   column names are genes, rows are samples
expressionData = read.csv(opt$expressionData, header = TRUE, row.names = 1)

cat("Calculate R power table\n")
powers = seq(1, opt$betaMaximum)
RpowerTable = pickSoftThreshold(expressionData, powerVector = powers)[[2]]
cat("write R power table into file\n")
write.csv(RpowerTable, file=opt$rPowerTableOutput)


pdf(file = opt$scaleFreeFitPlot)

Rpower = RpowerTable[,1]
# plot scale free fit R^2 versus different soft threshold beta
signedRSq = -sign(RpowerTable[, 3]) * RpowerTable[, 2]
Rpower_df = data.frame(Rpower, signedRSq)

p = ggplot(aes(x = Rpower, y = signedRSq), data = Rpower_df)
p + geom_label(label = Rpower, color = "red") +
  xlab("R power") +
  ylab(expression("Scale Free Topology Model Fit, Signed "~R^2)) +
  geom_hline(yintercept = 0.95, color = "blue")

# mean connectivity versus different soft threshold beta
meanConn = RpowerTable[,5]
meanConn_df = data.frame(Rpower, meanConn)
p = ggplot(aes(x = Rpower, y = meanConn), data = meanConn_df)
p + geom_label(label = Rpower, color = "red") +
  xlab("R power") +
  ylab("Mean connectivity")

dev.off()