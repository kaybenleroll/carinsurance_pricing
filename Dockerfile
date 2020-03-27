FROM rocker/rstudio:3.5.1


RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libxml2-dev \
    zlib1g-dev \
  && apt-get clean \
  && install2.r --error \
    tidyverse \
    data.table \
    dtplyr \
    GGally \
    feather \
    Boruta \
    poweRlaw \
    caTools \
    xts \
    sp \
    rprojroot \
    sessioninfo \
    arm


RUN Rscript -e 'install.packages("CASdatasets", repos = "http://cas.uqam.ca/pub/R/", type="source")'

