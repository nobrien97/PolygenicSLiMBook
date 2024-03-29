# Code generated by SLiM Runner: https://github.com/nobrien97/PolygenicSLiMBook/tree/main/src/Tools/SLiMRunGen
USER <- Sys.getenv('USER')

library(foreach)
library(doParallel)
library(future)

cl <- makeCluster(future::availableCores())

registerDoParallel(cl)
seeds <- read.csv("seeds.csv", header = T)
combos <- read.csv("combos.csv", header = T)
foreach(i=1:nrow(combos)) %:%
	foreach(j=seeds$Seed) %dopar% {
		slim_out <- system(sprintf("/home/$USER/SLiM/slim -s %s -d s=%s -d mig_rate=%s ~/Desktop/slimrun.slim", as.character(j), combos[i,]$s, combos[i,]$mig_rate, intern=T))
  }
stopCluster(cl)
