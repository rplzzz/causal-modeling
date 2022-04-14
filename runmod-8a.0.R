library(cmdstanr)

datafile <- 'concord-8a.rds'
stanfile <- 'concord-8.0.stan'
outfile <- 'mod8a.0.rds'

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4)
  rstan::read_stan_csv(mx$output_files())
}

indata <- readRDS(datafile)
m8a.0 <- cmdstan2rstan(stanfile, indata)
saveRDS(m8a.0, outfile)
