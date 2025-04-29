packages <- c("ggplot2", "ggthemes", "scales", "dplyr", "mice", "randomForest", "ranger")

install.packages(packages, repos='http://cran.r-project.org', Ncpus=30)
all(packages %in% rownames(installed.packages())) || quit(status = 1)

