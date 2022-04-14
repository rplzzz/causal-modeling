// Concordance model 7.3: Use a low-quality proxy for SES in place of SES (i.e, without
// trying to impute)
functions {
  real logodds(data int [] X, data int N) {
    real Nx = sum(X);
    real px = Nx / N;

    print("\tNx: ", Nx, " px: ", px, " logit(px): ", logit(px)); 
    
    return logit(px);
  }
  
}
data {
  int<lower=0> N;
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> O[N];
  int<lower=0, upper=1> D[N];
  vector[N] I;               
}
transformed data {
  real ao0;
  real ad0;

  print("Calc ao0");
  ao0 = logodds(O, N);  // base rate outcome
  print("Calc ad0");
  ad0 = logodds(D, N);	// base rate medicaid
  print("ad0 = ", ad0);
}

parameters {
  real bsu;			// sex effect on mean SES
  real bhu;			// HNW effect on mean SES

  real<lower=0> bud;            // SES effect on medicaid, presumed positive (together with the
                                // sign convention below, this implies higher SES lowers the prob.
                                // of being enrolled in medicaid.
  real ad;			// base rate medicaid

  real ao;			// base rate for outcome
  real bso;			// sex effect on outcome
  real bho;			// HNW effect on outcome
  real buo;                      // SES effect on outcome.  I think this can be assumed to be 1,
                                // since it only appears when multiplied by another parameter, never
                                // by itself.  (Note we _subtract_ this term in the outcome)
  real<lower=0> sigus;	       // scale factor for I residuals to the mean SES
}

model {
  vector[N] SES_mean;  // latent socioeconomic status
  vector[N] pO;	       // accumulator variable for outcome probability
  vector[N] pD;      // accumulator for other var probabilities.
  
  // priors for all parameters
  bsu ~ normal(0, 0.5);
  bhu ~ normal(0, 0.5);

  bud ~ normal(0, 0.5);
  ad ~ normal(0, 0.5);

  ao ~ normal(0, 0.5);
  bso ~ normal(0, 0.5);
  bho ~ normal(0, 0.5);
  buo ~ normal(0, 0.5);

  sigus ~ exponential(0.5);


  // latent SES variable
  for (i in 1:N) {
    SES_mean[i] = bsu*S[i] + bhu*H[i];
  }
  I ~ normal(SES_mean, sigus);	// Include SES truth value.
  
  // medicaid: base rate + SES effect.
  for (i in 1:N) {
    pD[i] = ad - bud*I[i]; // Effect of higher SES presumed to be negative.
  }
  D ~ bernoulli_logit(pD);

  // outcome
  for (i in 1:N) {
    pO[i] = ao + bso*S[i] + bho*H[i] + buo*I[i];
  }
  
  O ~ bernoulli_logit(pO);
}
generated quantities {
  real ADCE_H;  // Average direct causal effect of H
  real ADRR_H;  // Average direct relative risk due to H
  
  {
    real lp0;    // logit of p when H==0
    
    vector[N] p_h0;   // p(O | do(H==0))
    vector[N] p_h1;   // p(O | do(H==1))
    vector[N] rr;     // relative risk
    
    for (i in 1:N) {
      lp0 =  ao + bso*S[i] + buo*I[i];
      
      p_h0[i] = inv_logit(lp0);
      p_h1[i] = inv_logit(lp0 + bho);
    }
    ADCE_H = mean(p_h1 - p_h0);
    for(j in 1:N) {
      rr[j] = p_h1[j] / p_h0[j];
    }
    ADRR_H = mean(rr);
  }
}
