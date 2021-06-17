# Script to generate a Latin hypercube for two parameters

library(DoE.wrapper)

# Sample a random 32 bit int as a seed for the LHC generation
lhc_seed <- sample(0:.Machine$integer.max, 1)

# In the example in chapter 8, this is 1868057774

lhc <- lhs.design(
  nruns = 512,
  nfactors = 2,
  type = "maximin",
  factor.names = list(
    param1 = c(0.0, 1.0),
    param2 = c(100, 20000)),
  seed = lhc_seed
)

# Diagnostics

# Plot param1 against param2 to visualise any obvious gaps in sampling and correlations
plot(lhc)

# Return a matrix of correlations between factors
cor(lhc)

# Plot the histograms to check uniformity
hist(lhc$param1)
hist(lhc$param2)

# Save the output to file

write.csv(lhc, "./LHC.csv")

