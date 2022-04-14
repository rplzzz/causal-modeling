#### Simulate data from various causal models of the concordance project

rbern_logit <- function(N, x)
{
  logp <- ifelse(x < 0,
                 x - log1p(exp(x)),
                 -log1p(exp(-x)))
  p <- exp(logp)
  rbinom(N, 1, p)
}

## parms: a named list of model parameters
sim_concord_1 <- function(N, parms = NULL) 
{
  default_parms <- list(
    ac = 0.0,     # baseline concordance
    ad = -1.0,    # baseline dual eligible
    ao = -2.3,    # baseline outcome (p(death))
    
    bc1 = -2,    # spec=1 effect on concordance
    bc2 = -0.5,  # weekend effect on concordance
    
    bus1 = 0,     # sex effect on SES (assume none, but leave possibility open)
    bus2 = -0.5,  # HNW effect on SES (with ad=bd=-1, this implies ~38% of HNW
                  # will be DE.)
    bus3 = -0.25, # OSH effect on SES (OSH associated with lower SES)
    
    bd = -1.0,    # unobserved socioeconomic status effect on dual eligibility
                  # (low values of latent SES associated with dual elig.)
    
    ## Direct effect on outcomes. +ve = higher p(death)
    bo1 = 1.0,    # spec = 1 effect on p(death)
    bo2 = 0.1,    # weekend effect on p(death)
    bo3 = -0.3,   # concordance effect on p(death)
    bo4 = 0.0,    # sex effect on outcome - assume none, but leave possibility open
    bo5 = 0.2,    # HNW direct effect on outcome - this is the primary object of study
    bo6 = 0.5,    # SES effect on outcome - this is the main confounding pathway
    bo7 = 0.1,    # OSH effect on outcome - modest negative effect
    bo8 = -1.0,   # Elective admission effect on p(death)
    bo9 = 0,      # ED effect on p(death) (baseline case)
    
    ## Root node probabilities
    
    pspec = rep(0.25, 4),  # 4 specialties, equal probability
    pw = 0.15,             # 15% of pts on weekends
    ps = 0.5,              # equal distribution of sexes
    ph = 0.2,              # 20% HNW
    psrc = c(0.2, 0.1, 0.7) # admissions source prob: OSH, elective, ED
  )
 
  p <- default_parms
  for (n in parms) {
    if(! n %in% names(default_parms)) {
      warning('Unknown parameter: ', n)
    }
    p[[n]] <- parms[[n]]
  }
  
  if(length(p$pspec) != 4) {
    stop('pspec must have length 4')
  }
  if(length(p$psrc) != 3) {
    stop('psrc must have length 3')
  }
  
  ## Start by generating the root variables
  SPEC <- sample(seq(1,4), N, TRUE, p$pspec)
  W <- rbinom(N, 1, p$pw)
  S <- rbinom(N, 1, p$ps)
  H <- rbinom(N, 1, p$ph)
  adm <- sample(seq(1,3), N, TRUE, p$psrc)
  
  ## Derived inputs
  OSH <- ifelse(adm==1, 1, 0)
  El <- ifelse(adm==2, 1, 0)
  ED <- ifelse(adm==3, 1, 0)
  spc1 <- ifelse(SPEC==1, 1, 0)
  
  ## unobserved variables
  us <- rnorm(N) + p$bus1*S + p$bus2*H + p$bus3*OSH
  
  ## non-root variables
  C <- rbern_logit(N, p$ac + p$bc1*spc1 + p$bc2*W)
  D <- rbern_logit(N, p$ad + p$bd*us)
  
  ## outcome variable
  po <- p$ao + p$bo1*spc1 + p$bo2*W + p$bo3*C + p$bo4*S +
    p$bo5*H + p$bo6*us + p$bo7*OSH + p$bo8*El + p$bo9*ED
  O <- rbern_logit(N, po)
  
  ## package evrything up in a data frame.  We'll include the unobserved variables,
  ## but using them in the modeling is verboten, unless to demonstrate the effect of bias.
  
  tibble::tibble(
    SPEC1 = SPEC==1,
    SPEC2 = SPEC==2,
    SPEC3 = SPEC==3,
    SPEC4 = SPEC==4,
    W = W,
    S = S,
    H = H,
    OSH = OSH,
    EL = El,
    ED = ED,
    C = C,
    D = D,
    O = O,
    us = us
  )
}

set.seed(867-5309)
concord_1_n1000 <- as.list(sim_concord_1(1000))
concord_1_n1000$N <- 1000
set.seed(867-5309)
concord_1_n20000 <- as.list(sim_concord_1(20000))
concord_1_n20000$N <- 20000
