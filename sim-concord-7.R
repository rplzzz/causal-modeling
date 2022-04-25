#### Simulate data from various causal models of the concordance project

#### Model 7: Simplified model:  Get rid of everything not touching SES, get rid
#### of admissions (for now)

rbern_logit <- function(N, x)
{
  logp <- ifelse(x < 0,
                 x - log1p(exp(x)),
                 -log1p(exp(-x)))
  p <- exp(logp)
  rbinom(N, 1, p)
}

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

## parms: a named list of model parameters
sim <- function(N, parms = NULL)
{
  default_parms <- list(
    ao = -2.3,    # baseline outcome (p(death))

    bsu = 0,     # sex effect on SES (assume none, but leave possibility open)
    bhu = -0.5,  # HNW effect on SES
    sigus = 1.0, # Random component of SES

    dthresh = -0.75, # SES threshold for Medicaid eligibility (together with bhu
                     # = -0.5, this equates to about 40% of HNW are medicaid eligible.

    sigi0 = 0.05,    # Noise level in the high-quality proxy for SES.
    sigi = 0.707,    # Noise level in the regular proxy for SES. Default is half the variance
                     # of the default sigus

    ## Direct effect on outcomes. +ve = higher p(death)
    bso = 0.0,    # sex effect on outcome - assume none, but leave possibility open
    bho = 0.2,    # HNW direct effect on outcome - this is the primary object of study
    buo = -0.5,    # SES effect on outcome - this is the main confounding pathway

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

  ## other non-root variables
  D <- ifelse(us > p$dthresh, 0, 1)

  ## outcome variable
  po <- p$ao + p$bso*S + p$bho*H + p$buo*us
  O <- rbern_logit(N, po)

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
    logitpo_H0 = p$ao + p$bso*S + p$buo*us,
    logitpo_H1 = p$ao + p$bso*S + p$buo*us + p$bho,
    N=N
  )
}

set.seed(867-5309)
concord_7 <- sim(20000)
#saveRDS(concord_7, 'concord-7.rds')

set.seed(867-5309)
concord_7a <- sim(20000, list(buo=0, ao=-2.15))
#saveRDS(concord_7a, 'concord-7a.rds')

## Dataset 7B illustrates the bias that can occur if we don't control for S.
## The size of the effect depends on the parameters.  These parameters cause the
## model value for bho to roughly double if S is omitted.
set.seed(867-5309)
concord_7b <- sim(20000, list(bsu=1, bso=1, bhu=-1))
saveRDS(concord_7b, 'concord-7b.rds')

set.seed(23)
concord_7c <- sim(20000)
saveRDS(concord_7c, 'concord-7c.rds')
