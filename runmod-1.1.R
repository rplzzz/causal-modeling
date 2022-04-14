library('rstan')

datafile <- 'concord-1-n20000.rds'
stanfile <- 'concord-2.stan'
outfile <- 'mod2.1_n20000.rds'

indata <- readRDS(datafile)

mod <- stan(stanfile, data=indata, cores=4,
            seed=867-5309, iter=4000, warmup=2000)

saveRDS(mod, outfile)

message('Outfile is ', outfile)
