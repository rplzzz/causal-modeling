// Concordance model 2: ignore the random component of US
functions {
  real logodds(data int [] X, data int N) {
    real Nx = sum(X);
    real px = Nx / N;

    return logit(px);
  }
}
data {
  int<lower=0> N;
  int<lower=0> SPEC[N];
  int<lower=0> ADM[N];
  int<lower=0, upper=1> W[N];
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> C[N];
  int<lower=0, upper=1> O[N];
  int<lower=0, upper=1> D[N];

  vector[N] I;
}
transformed data {
  int OSH[N];
  real ao = logodds(O, N);	// baseline outcome
  real ac = logodds(C, N);	// baseline concordance
  
  
  for(i in 1:N) {
    OSH[i] = (SPEC[i] == 1);
  }
}
parameters {
  vector[4] bspc;		// SPEC effect on concordance
  real bwc;			// weekend effect on concordance

  real bsu;			// sex effect on SES
  real bhu;			// HNW effect on SES

  real bua;			// SES effect on ADM
  real aosh;			// baseline OSH component of ADM

  vector[4] bspo;		// SPEC effect on outcome
  real bwo;			// weekend effect on outcome
  real bco;			// concordance effect on outcome
  real bso;			// sex effect on outcome
  real bho;			// HNW effect on outcome
  real buo;			// SES effect on outcome
  vector[3] bao;		// ADM effect on outcome

  vector[N] SES;		// unobserved SES

  real<lower=0> sigus;		// SES stddev
  real<lower=0> sigi;		// noise in the "income" measurement.
}

model {
  vector[N] SES_mean;		// conditional mean of SES
  vector[N] ptmp;		// accumulator variable for probs
  vector[N] unnorm_osh;		// OSH unnorm prob
  vector[N] p_osh;		// OSH norm prob
  
  // priors for all parameters
  bspc ~ normal(0, 0.5);
  bwc ~ normal(0, 0.5);

  bsu ~ normal(0, 0.5);
  bhu ~ normal(0, 0.5);
  bua ~ normal(0, 0.5);

  bspo ~ normal(0, 0.5);
  bwo ~ normal(0, 0.5);
  bco ~ normal(0, 0.5);
  bso ~ normal(0, 0.5);
  bho ~ normal(0, 0.5);
  buo ~ normal(0, 0.5);
  bao ~ normal(0, 0.5);

  sigus ~ exponential(1);
  sigi ~ exponential(1);

  // fix scale for categorical params
  bao[3] ~ normal(0, 0.01);            // ED is the baseline for admission effect on outcome
  // drop this next constraint b/c we have frozen the intercept term for O
  //sum(bspo) ~ normal(0, 0.01);        // no obvious baseline for specialty, so constrain the mean

  // latent SES variable
  for (i in 1:N) {
    SES_mean[i] = bsu*S[i] + bhu*H[i];
  }
  SES ~ normal(SES_mean, sigus);
  I ~ normal(SES, sigi);
  
  // intermediate observed variables
  for (i in 1:N) {
    ptmp[i] = ac + bspc[SPEC[i]] + bwc*W[i];
  }
  C ~ bernoulli_logit(ptmp);

  // SES effect on OSH prob.  This is rather crude. In particular, we are fixing 
  // the logits for elective and ED admisions
  unnorm_osh = exp(aosh + bua*SES);
  for (i in 1:N) {
    p_osh[i] = unnorm_osh[i] / (unnorm_osh[i] + 1.0/7.0 + 1.0);
  }
  OSH ~ bernoulli(p_osh);

  // outcome
  for (i in 1:N) {
    ptmp[i] = ao + bspo[SPEC[i]] + bwo*W[i] + bco*C[i] + bso*S[i] + bho*H[i] +
      buo*SES[i] + bao[ADM[i]];
  }
  
  O ~ bernoulli_logit(ptmp);
}

