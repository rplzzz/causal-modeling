library(cmdstanr)

datafile <- 'concord-4.rds'
stanfile <- 'concord-4.4.stan'         
outfile <- 'mod4.4.rds'

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4,
                   iter_warmup = 4000, iter_sampling = 2000)
  rstan::read_stan_csv(mx$output_files())
}

indata <- readRDS(datafile)
m4.4 <- cmdstan2rstan(stanfile, indata)
