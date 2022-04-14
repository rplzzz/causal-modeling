library(cmdstanr)

datafile <- 'concord-6.rds'
stanfile <- 'concord-6.1.stan'    # the model for concord-5 is the same as the one for concord-4;
                                  # only the input data is different.
outfile <- 'mod6.1.rds'

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4)#,
                   #iter_warmup = 4000, iter_sampling = 2000)
  rstan::read_stan_csv(mx$output_files())
}

indata <- readRDS(datafile)
m6.1 <- cmdstan2rstan(stanfile, indata)
saveRDS(m6.1, outfile)
