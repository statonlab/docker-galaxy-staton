# Galaxy REPLACEMENT
#
# VERSION 0.1

FROM quay.io/bgruening/galaxy:16.10

MAINTAINER Ming Chen, ming.chen0919@gmail.com

ENV GALAXY_CONFIG_BRAND DNA mapping

##========= General section ======================
## Add conda bin directory to the PATH
## Add channels to conda:
##		- bioconda
##		- R
## Create $GALAXY_ROOT/tool_yml_files directory
## Create $GALAXY_ROOT/my_tools directory
## 		Install linuxbrew
##================================================
RUN echo "## Add conda bin to $PATH" >> /home/galaxy/.bashrc && \
    echo PATH=/tool_deps/_conda/bin:$PATH >> /home/galaxy/.bashrc && \
    /tool_deps/_conda/bin/conda config --add channels bioconda && \
    /tool_deps/_conda/bin/conda config --add channels R && \
    mkdir $GALAXY_ROOT/tool_yml_files && \
    apt-get update && \
    apt-get install -y ruby && \
    sudo -u galaxy ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
##========= Section end ==========================


##========= BDSS Tools ===========================
## Tools included:
##		- BDSS
##================================================
## install bdss from PyPI
RUN /tool_deps/_conda/bin/pip install bdss-client
## add bdss.xml and defaults.cfg
ADD my_tools/bdss-client/bdss.xml $GALAXY_ROOT/tools/data_source/
ADD my_tools/bdss-client/defaults.cfg /tool_deps/_conda/client/defaults.cfg
##========= Section end ==========================

##============= import workflows from a local directory ========
##	start galaxy
##	add ./my_workflows to ~/workflows
##	add ./my_scripts to ~/my_scripts
##	run python script to import workflows
##==============================================================
ADD my_workflows $GALAXY_HOME/my_workflows
ADD my_scripts $GALAXY_HOME/my_scripts
ADD my_tools/import_workflows/ $GALAXY_ROOT/my_tools/import_workflows/
RUN pip install bioblend


##============ install R-3.2.5 ======================
##
##===================================================
RUN sudo apt-get -y build-dep r-base
RUN cd /opt && wget https://cran.r-project.org/src/base/R-3/R-3.2.5.tar.gz && \
    tar xzf R-3.2.5.tar.gz && cd R-3.2.5 && \
    ./configure --prefix=/opt/R/3.2.5 --enable-R-shlib --with-blas --with-lapack && \
    make && \
    sudo make install


# ## ////////// install tools from galaxy toolshed /////////////////////
ADD tool_yml_files/abyss.yml $GALAXY_HOME/tool_yml_files/abyss.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/abyss.yml

ADD tool_yml_files/bowtie2.yml $GALAXY_HOME/tool_yml_files/bowtie2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/bowtie2.yml

ADD tool_yml_files/bwa.yml $GALAXY_HOME/tool_yml_files/bwa.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/bwa.yml

ADD tool_yml_files/cuffdiff-2.2.1.2.yml $GALAXY_HOME/tool_yml_files/cuffdiff-2.2.1.2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/cuffdiff-2.2.1.2.yml

ADD tool_yml_files/differential_count_models-0.28.yml $GALAXY_HOME/tool_yml_files/differential_count_models-0.28.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/differential_count_models-0.28.yml

ADD tool_yml_files/fasta_extract.yml $GALAXY_HOME/tool_yml_files/fasta_extract.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/fasta_extract.yml

ADD tool_yml_files/fasta_stats.yml $GALAXY_HOME/tool_yml_files/fasta_stats.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/fasta_stats.yml

ADD tool_yml_files/fastq_groomer.yml $GALAXY_HOME/tool_yml_files/fastq_groomer.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/fastq_groomer.yml

ADD tool_yml_files/fastq_to_fasta.yml $GALAXY_HOME/tool_yml_files/fastq_to_fasta.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/fastq_to_fasta.yml

ADD tool_yml_files/fastqc.yml $GALAXY_HOME/tool_yml_files/fastqc.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/fastqc.yml

ADD tool_yml_files/flagstat.yml $GALAXY_HOME/tool_yml_files/flagstat.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/flagstat.yml

ADD tool_yml_files/freebayes.yml $GALAXY_HOME/tool_yml_files/freebayes.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/freebayes.yml

ADD tool_yml_files/gatk2.yml $GALAXY_HOME/tool_yml_files/gatk2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/gatk2.yml

ADD tool_yml_files/hisat2.yml $GALAXY_HOME/tool_yml_files/hisat2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/hisat2.yml

ADD tool_yml_files/htseq_bams_to_count_matrix-0.5.yml $GALAXY_HOME/tool_yml_files/htseq_bams_to_count_matrix-0.5.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/htseq_bams_to_count_matrix-0.5.yml

ADD tool_yml_files/miraligner.yml $GALAXY_HOME/tool_yml_files/miraligner.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/miraligner.yml

ADD tool_yml_files/mirdeep2.yml $GALAXY_HOME/tool_yml_files/mirdeep2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/mirdeep2.yml

ADD tool_yml_files/mirdeep2_mapper.yml $GALAXY_HOME/tool_yml_files/mirdeep2_mapper.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/mirdeep2_mapper.yml

ADD tool_yml_files/mirdeep2_quantifier.yml $GALAXY_HOME/tool_yml_files/mirdeep2_quantifier.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/mirdeep2_quantifier.yml

ADD tool_yml_files/prop_venn.yml $GALAXY_HOME/tool_yml_files/prop_venn.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/prop_venn.yml

ADD tool_yml_files/rgrnastar.yml $GALAXY_HOME/tool_yml_files/rgrnastar.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/rgrnastar.yml

ADD tool_yml_files/tophat2-0.9.yml $GALAXY_HOME/tool_yml_files/tophat2-0.9.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/tophat2-0.9.yml

ADD tool_yml_files/tophat2.yml $GALAXY_HOME/tool_yml_files/tophat2.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/tophat2.yml

ADD tool_yml_files/trimmomatic.yml $GALAXY_HOME/tool_yml_files/trimmomatic.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/trimmomatic.yml

ADD tool_yml_files/trinity.yml $GALAXY_HOME/tool_yml_files/trinity.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/trinity.yml

ADD tool_yml_files/vilvetoptimiser.yml $GALAXY_HOME/tool_yml_files/vilvetoptimiser.yml
RUN install-tools $GALAXY_HOME/tool_yml_files/vilvetoptimiser.yml
## /////////////  end of install tools from galaxy toolshed  //////////////////





##========== replace tool config files =========================
##
##
##==============================================================
## replace the tool_config.xml file
# ADD tool_conf.xml $GALAXY_ROOT/config/tool_conf.xml

#
# RUN cp $GALAXY_HOME/tool_sheds_conf.xml $GALAXY_ROOT/config/tool_sheds_conf.xml