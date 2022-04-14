#### Simulate data from various causal models of the concordance project

#### Model 8: Model 7 + admission status

### Random bernoulli deviates, from logit values
rbern_logit <- function(N, x)
{
  logp <- ifelse(x < 0,
                 x - log1p(exp(x)),
                 -log1p(exp(-x)))
  p <- exp(logp)
  rbinom(N, 1, p)
}

### Random multinomial deviates, from logit values
## l: a matrix of logit values with N rows, k columns
rmulti_logit <- function(N, l)
{
  unprob <- exp(l)
  sprob <- apply(unprob, 1, sum)
  prob <- sweep(unprob, 1, sprob, '/') # N x k matrix of probs.

  r <- runif(N)
  rslt <- rep(NA_integer_, N)

  for(k in seq(1, ncol(l))) {
    sel <- r > 0 & r <= prob[,k]
    rslt[sel] <- k
    r <- r - prob[,k]
  }

  stopifnot(!any(is.na(rslt)))

  rslt
}

### Logit and inverse logit functions
logit <- function(x)
{
  ## log(x/(1-x)) = log(x) - log(1 + (-x))
  log(x) - log1p(-x)
}

inv_logit <- function(x)
{
  y <- exp(x)
  ifelse(x < 0, y/(1+y), 1/(1+exp(-x)))
}

## parms: a named list of model parameters
sim <- function(N, parms = NULL)
{
  default_parms <- list(
    ao = -2.375,    # baseline outcome (p(death)) -- Adjusted to get P(O)
                    # approximately equal to what we saw in Dataset 7

    bsu = 0,     # sex effect on SES (assume none, but leave possibility open)
    bhu = -0.5,  # HNW effect on SES
    sigus = 1.0, # Random component of SES

    dthresh = -0.75, # SES threshold for Medicaid eligibility (together with bhu
                     # = -0.5, this equates to about 40% of HNW are medicaid eligible.

    sigi0 = 0.05,    # Noise level in the high-quality proxy for SES.
    sigi = 0.707,    # Noise level in the regular proxy for SES. Default is half the variance
                     # of the default sigus

    adm0 = log(c(20,10,70)),            # baseline admissions dist.
    ## SES effect on admission
    bua = list(
      c(-0.3, 0.25, 0),                 # SES > 0
      c(-0.3, 0, 0)),                    # SES < 0


    ## Direct effect on outcomes. +ve = higher p(death)
    bso = 0.0,    # sex effect on outcome - assume none, but leave possibility open
    bho = 0.2,    # HNW direct effect on outcome - this is the primary object of study
    buo = -0.5,    # SES effect on outcome - this is the main confounding pathway
    badmo = c(0.5, -1.0, 0),  # Admissions effect on outcome

    ## Root node probabilities

    ps = 0.5,              # equal distribution of sexes
    ph = 0.2               # 20% HNW
  )

  p <- default_parms
  for (n in names(parms)) {
    if(! n %in% names(default_parms)) {
      warning('Unknown parameter: ', n)
    }
    p[[n]] <- parms[[n]]
  }

  ## Start by generating the root variables
  S <- rbinom(N, 1, p$ps)
  H <- rbinom(N, 1, p$ph)

  ## unobserved variables
  us <- rnorm(N, sd=p$sigus) + p$bsu*S + p$bhu*H

  ## noisy measurement of us
  I <- us + rnorm(N, sd=p$sigi)
  I0 <- us + rnorm(N, sd=p$sigi0)

  ## admission status
  adm0 <- matrix(rep(p$adm0, N), nrow=N, byrow=T)
  logitp0 <- adm0 + t(sapply(us, function(x) {if(x>0) x*p$bua[[1]] else x*p$bua[[2]]}))
  adm <- rmulti_logit(N, logitp0)

  ## other non-root variables
  D <- ifelse(us > p$dthresh, 0, 1)

  ## outcome variable
  po <- p$ao + p$bso*S + p$bho*H + p$buo*us + p$badmo[adm]
  O <- rbern_logit(N, po)

  message('P(O) = ', sum(O) / length(O))

  ## package everything up in a data frame.  We'll include the unobserved variables,
  ## but using them in the modeling is verboten, unless to demonstrate the effect of bias.

  list(
    S = S,
    H = H,
    D = D,
    I = I,
    I0 = I0,
    O = O,
    uSES = us,
    adm=adm,
    logitpo_H0 = p$ao + p$bso*S + p$buo*us + p$badmo[adm],
    logitpo_H1 = p$ao + p$bso*S + p$buo*us + p$badmo[adm] + p$bho,
    N=N,
    n_adm=max(adm)
  )
}

set.seed(867-5309)
concord_8 <- sim(20000)
#saveRDS(concord_8, 'concord-8.rds')

set.seed(867-5309)
concord_8a <- sim(20000, list(buo=0, ao=-2.22))
#saveRDS(concord_8a, 'concord-8a.rds')

set.seed(867-5309)
concord_8b <- sim(20000, list(buo=0, bho=0, ao=-2.18))
saveRDS(concord_8b, 'concord-8b.rds')
