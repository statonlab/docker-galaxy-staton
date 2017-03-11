## Install tools with conda

* mirdeep2 (2.0.0.8)

```
/tool_deps/_conda/bin/conda install -y mirdeep2==2.0.0.8
```

* trinity (2.2.0)

```
/tool_deps/_conda/bin/conda install -y trinity==2.2.0
```

* snpEff (4.1l)

```
/tool_deps/_conda/bin/conda install -y snpeff==4.1l
```

* freeBayes (1.1.0)

```
/tool_deps/_conda/bin/conda install -y freebayes==1.1.0
```

## Install R packages from bioconda

* DESeq2

    + install required ubuntu package:
    
        `sudo apt-get install -y libxml2-dev`

```
## R script for package installation: install-DESeq2.R
source("http://bioconductor.org/biocLite.R")
biocLite('XML')
biocLite('annotate')
biocLite('genefilter')
biocLite('geneplotter')
biocLite("DESeq2")

```

```
sudo /opt/R-3.2.5/bin/Rscript install-DESeq2.R
```

* edgeR

```
## R script for package installation: install-edgeR.R
source("http://bioconductor.org/biocLite.R")
biocLite('edgeR')
```

```
sudo /opt/R-3.2.5/bin/Rscript install-edgeR.R
```


* WGCNA

```
# R script for package installation: install-WGCNA.R
source("http://bioconductor.org/biocLite.R")
biocLite(c("AnnotationDbi", "impute", "GO.db", "preprocessCore"))
install.packages("WGCNA", repos = "http://cran.us.r-project.org")
```

```
sudo /opt/R-3.2.5/bin/Rscript install-WGCNA.R
```