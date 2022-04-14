#### Simulate data from various causal models of the concordance project

#### Model 4: add a noisy measurement of US

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
sim_concord_6 <- function(N, parms = NULL)
{
  default_parms <- list(
    ac = 0.0,     # baseline concordance
    ad = -1.0,    # baseline dual eligible
    ao = -2.3,    # baseline outcome (p(death))

    bspc = c(-2, 0, 0, 0),   # specialty effects on concordance
    bwc = -0.5,  # weekend effect on concordance

    bsu = 0,     # sex effect on SES (assume none, but leave possibility open)
    bhu = -0.5,  # HNW effect on SES
    sigus = 1.2, # Random component of SES

    bua = -0.25, # SES effect on OSH (higher SES -> lower OSH)

    dthresh = -0.75, # SES threshold for Medicaid eligibility (together with bhu
                     # = -0.5, this equates to about 40% of HNW are medicaid eligible.

    sigi = 0.85,    # Noise level in the proxy for sigus. Default is half the variance
                    # of the default sigus

    ## Direct effect on outcomes. +ve = higher p(death)
    bspo = c(1.0, 0.0, 0.0, 0.0),    # spec = 1 effect on p(death)
    bwo = 0.1,    # weekend effect on p(death)
    bco = -0.3,   # concordance effect on p(death)
    bso = 0.0,    # sex effect on outcome - assume none, but leave possibility open
    bho = 0.2,    # HNW direct effect on outcome - this is the primary object of study
    buo = 0.5,    # SES effect on outcome - this is the main confounding pathway
    ## Admission status effect on outcome. OSH is modest increase in mortality,
    ## Elective is big decrease, ED is baseline
    bao = c(0.1, -1.0, 0),

    ## Root node probabilities

    pspec = rep(0.25, 4),  # 4 specialties, equal probability
    pw = 0.15,             # 15% of pts on weekends
    ps = 0.5,              # equal distribution of sexes
    ph = 0.2,              # 20% HNW
    lsrc = log(c(2, 1, 7)/7)    # baseline admissions source multinomial logit value: OSH, elective, ED
  )

  p <- default_parms
  for (n in names(parms)) {
    if(! n %in% names(default_parms)) {
      warning('Unknown parameter: ', n)
    }
    p[[n]] <- parms[[n]]
  }

  if(length(p$pspec) != 4) {
    stop('pspec must have length 4')
  }
  if(length(p$lsrc) != 3) {
    stop('psrc must have length 3')
  }
  if(length(p$bao) != 3) {
    stop('bao must have length 3')
  }

  ## Start by generating the root variables
  SPEC <- sample(seq(1,4), N, TRUE, p$pspec)
  W <- rbinom(N, 1, p$pw)
  S <- rbinom(N, 1, p$ps)
  H <- rbinom(N, 1, p$ph)

  ## unobserved variables
  us <- rnorm(N, sd=p$sigus) + p$bsu*S + p$bhu*H

  ## noisy measurement of us
  I <- us + rnorm(N, sd=p$sigi)

  ## admission status
  l <- matrix(rep(p$lsrc, N), nrow=N, byrow=TRUE)
  l[,1] <- l[,1] + p$bua * us   # SES effect on p(OSH)
  Adm <- rmulti_logit(N, l)

  ## other non-root variables
  C <- rbern_logit(N, p$ac + p$bspc[SPEC] + p$bwc*W)
  D <- ifelse(us > p$dthresh, 0, 1)

  ## outcome variable
  po <- p$ao + p$bspo[SPEC] + p$bwo*W + p$bco*C + p$bso*S +
    p$bho*H + p$buo*us + p$bao[Adm]
  O <- rbern_logit(N, po)

  ## package everything up in a data frame.  We'll include the unobserved variables,
  ## but using them in the modeling is verboten, unless to demonstrate the effect of bias.

  list(
    SPEC = SPEC,
    W = W,
    S = S,
    H = H,
    ADM = Adm,
    C = C,
    D = D,
    I = I,
    O = O,
    us = us,
    N=N
  )
}

set.seed(867-5309)
concord_6_n20000 <- sim_concord_6(20000)
saveRDS(concord_6_n20000, 'concord-6.rds')
