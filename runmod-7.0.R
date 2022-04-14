library(cmdstanr)

datafile <- 'concord-7.rds'
stanfile <- 'concord-7.0.stan'    # the model for concord-5 is the same as the one for concord-4;
                                  # only the input data is different.
outfile <- 'mod7.0.rds'

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4)#,
                   #iter_warmup = 4000, iter_sampling = 2000)
  rstan::read_stan_csv(mx$output_files())
}

indata <- readRDS(datafile)
m7.0 <- cmdstan2rstan(stanfile, indata)
saveRDS(m7.0, outfile)
