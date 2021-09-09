seeds <- runif(100, 0, .Machine$integer.max)
hist(seeds)

seeds <- read.csv("seeds.csv")
hist(seeds$Seed)

library(Rcpp)
# Implements the same function in Rcpp for easy testing
sourceCpp("/mnt/c/GitHub/LooseRScripts/seedgenrcpp.cpp")

# Pickover test
# “Pickover describes a simple but quite effective technique for testing RNGs visually. 
# The idea is to generate random numbers in groups of three, and to use each group to plot 
# a point in spherical coordinates. If the RNG is good, the points will form a solid sphere. 
# If not, patterns will appear. From: https://www.r-bloggers.com/2017/09/how-good-is-that-random-number-generator/
library(tidyverse)
library(gg3D)
points <- genNoiseSeeds(3000)
x <- points[seq(1, length(points), by = 3)]
y <- points[seq(2, length(points), by = 3)]
z <- points[seq(3, length(points), by = 3)]
df <- data.frame(x, y, z)

ggplot(df, aes(x=x, y=y, z=z)) +
  axes_3D() +
  stat_3D(alpha=.5) +
  theme_void()

library(GGally)