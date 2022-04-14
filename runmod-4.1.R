library('rstan')

datafile <- 'concord-4.rds'
stanfile <- 'concord-4.1.stan'         # Stan model for model 3 is the same as for model 2.
outfile <- 'mod4.1.rds'

indata <- readRDS(datafile)

mod <- stan(stanfile, data=indata, cores=4,
            seed=867-5309, iter=2000, warmup=1000)

saveRDS(mod, outfile)

message('Outfile is ', outfile)
