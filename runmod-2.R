library('rstan')

datafile <- 'concord-2.rds'
stanfile <- 'concord-2.stan'
outfile <- 'mod2.1.rds'

indata <- readRDS(datafile)

mod <- stan(stanfile, data=indata, cores=4,
            seed=867-5309, iter=2000, warmup=1000)

saveRDS(mod, outfile)

message('Outfile is ', outfile)
