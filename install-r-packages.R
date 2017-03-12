##========== packages from CRAN ============
pkgs = c('getopt', 'ggplot2', 'plyr', 'dplyr', 'ggdendro')
install.packages(pkgs, repos = "http://cran.us.r-project.org")

source("http://bioconductor.org/biocLite.R")


##========== bioconductor packages =========
## WGCNA
biocLite(c("AnnotationDbi", "impute", "GO.db", "preprocessCore", "netbiov"))
install.packages("WGCNA", repos = "http://cran.us.r-project.org")

## edgeR
biocLite('edgeR')

## DESeq2
deseq2_dependencies = c('XML', 'annotate', 'genefilter', 'geneplotter')
biocLite(deseq2_dependencies)
biocLite("DESeq2")