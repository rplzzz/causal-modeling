library(cmdstanr)

datafile <- 'concord-4.rds'
stanfile <- 'concord-4.5.stan'         
outfile <- 'mod4.5.rds'

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4)
  rstan::read_stan_csv(mx$output_files())
}

indata <- readRDS(datafile)
m4.5 <- cmdstan2rstan(stanfile, indata)
