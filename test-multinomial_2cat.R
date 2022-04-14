set.seed(867-5309)
N <- 1000
aadm <- log(c(20, 80))
bua <- list(
  c(-0.3, 0),
  c(-0.3, 0))

message('N = ', N)
message('aadm: ', paste(aadm, collapse=', '))
message('bua1: ', paste(bua[[1]], collapse=', '))
message('bua2: ', paste(bua[[2]], collapse=', '))


### Random multinomial deviates, from logit values
## l: a matrix of logit values with N rows, k columns.  Each row is softmax(p),
## where p is the vector of probabilities for a sample.
rmulti_logit <- function(N, l)
{
  unprob <- exp(l)
  sprob <- apply(unprob, 1, sum)
  prob <- sweep(unprob, 1, sprob, '/') # N x k matrix of probs.

  r <- runif(N)
  rslt <- rep(NA_integer_, N)

  for(k in seq(1L, ncol(l))) {
    sel <- r > 0 & r <= prob[,k]
    rslt[sel] <- k
    r <- r - prob[,k]
  }

  stopifnot(!any(is.na(rslt)))

  rslt
}

x <- rnorm(N)
ylogit <- t(sapply(x,
                   function(xx) {
                     if(xx > 0) {
                       aadm + xx * bua[[1]]
                     }
                     else {
                       aadm + xx * bua[[2]]
                     }
                   }))
stopifnot(dim(ylogit) == c(N, 2))
y <- rmulti_logit(N, ylogit)

yfl <- table(y[x < (-1)])/ sum(x < (-1))
yfh <- table(y[x > 1]) / sum(x > 1)

message('yfl: ', paste(yfl, collapse=', '))
message('yfh: ', paste(yfh, collapse=', '))

indata <- list(x=x, y=y, iy=y-1, N=N, nk=2)

cmdstan2rstan <- function(stanfile, indata) {
  mod <- cmdstan_model(stanfile)
  mx <- mod$sample(data=indata, seed=8675309, chains=4, parallel_chains=4)
  rstan::read_stan_csv(mx$output_files())
}

multi_2 <- cmdstan2rstan('test-multi.stan', indata)
logr_2 <- cmdstan2rstan('test-bern.stan', indata)

print(multi_2)
print(logr_2)


