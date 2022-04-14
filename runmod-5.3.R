library('rstan')

datafile <- 'concord-5.rds'
stanfile <- 'concord-4.3.stan'         # Stan model for model 5 is the same as for model 4.
outfile <- 'mod5.3.rds'

indata <- readRDS(datafile)

mod <- stan(stanfile, data=indata, cores=1,
            seed=867-5309, iter=2000, warmup=1000)

saveRDS(mod, outfile)

message('Outfile is ', outfile)
