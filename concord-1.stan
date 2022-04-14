// Concordance model 1
data {
  int<lower=0> N;
  int<lower=0, upper=1> SPEC1[N];
  int<lower=0, upper=1> SPEC2[N];
  int<lower=0, upper=1> SPEC3[N];
  int<lower=0, upper=1> SPEC4[N];
  int<lower=0, upper=1> W[N];
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> C[N];
  int<lower=0, upper=1> D[N];
  int<lower=0, upper=1> OSH[N];
  int<lower=0, upper=1> EL[N];
  int<lower=0, upper=1> ED[N];
  int<lower=0, upper=1> O[N];
}
parameters {
  real ac;			// baseline concordance
  real ad;			// baseline dual eligible
  real ao;			// baseline outcome

  real bc1;			// SPEC1 effect on concordance
  real bc2;			// weekend effect on concordance

  real bus1;			// sex effect on SES
  real bus2;			// HNW effect on SES
  real bus3;			// OSH effect on SES

  // SES effect on dual eligibility.  Requiring this to be negative is what
  // establishes the convention that higher values for the SES variable represent
  // greater affluence.
  //real<upper=0> bd;
  real<lower=0> sigus;

  real bo1;			// SPEC1 effect on outcome
  real bo2;			// weekend effect on outcome
  real bo3;			// concordance effect on outcome
  real bo4;			// sex effect on outcome
  real bo5;			// HNW effect on outcome
  real bo6;			// SES effect on outcome
  real bo7;			// OSH effect on outcome
  real bo8;			// EL effect on outcome
  real bo9;			// ED effect on outcome
  
  vector[N] usx;  // random component of unobserved SES
}

model {
  vector[N] us;
  vector[N] ptmp;
  
  // priors for all parameters
  ac ~ normal(0, 2);
  ad ~ normal(0, 2);
  ao ~ normal(0, 2);

  bc1 ~ normal(0, 2);
  bc2 ~ normal(0, 2);

  bus1 ~ normal(0, 2);
  bus2 ~ normal(0, 2);
  bus3 ~ normal(0, 2);

  //bd ~ normal(-1, 1);

  bo1 ~ normal(0, 2);
  bo2 ~ normal(0, 2);
  bo3 ~ normal(0, 2);
  bo4 ~ normal(0, 2);
  bo5 ~ normal(0, 2);
  bo6 ~ normal(0, 2);
  bo7 ~ normal(0, 2);
  bo8 ~ normal(0, 2);
  bo9 ~ normal(0, 2);

  // latent SES variable
  sigus ~ cauchy(0, 1);
  usx ~ normal(0, sigus);
  for (i in 1:N) {
    us[i] = usx[i] + bus1*S[i] + bus2*H[i] + bus3*OSH[i];
  }

  // intermediate observed variables
  for (i in 1:N) {
    ptmp[i] = ac + bc1*SPEC1[i] + bc2*W[i];
  }
  C ~ bernoulli_logit(ptmp);

  for (i in 1:N) {
    ptmp[i] = ad - us[i];   // subtracting us sets the sign convention.
  }
  D ~ bernoulli_logit(ptmp);
  

  // outcome
  for (i in 1:N) {
    ptmp[i] = ao + bo1*SPEC1[i] + bo2*W[i] + bo3*C[i] + bo4*S[i] + bo5*H[i] +
      bo6*us[i] + bo7*OSH[i] + bo8*EL[i] + bo9*ED[i];
  }
  
  O ~ bernoulli_logit(ptmp);
}

