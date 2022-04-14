// Concordance model 8.0: Total effect of HNW
data {
  int<lower=0> N;
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> O[N];
}
parameters {
  real ao;			// base rate for outcome
  real bso;			// sex effect on outcome
  real bho;			// HNW effect on outcome
}
model {
  vector[N] pO;	       // accumulator variable for outcome probability
  
  // priors for all parameters
  ao ~ normal(0, 0.5);
  bso ~ normal(0, 0.5);
  bho ~ normal(0, 0.5);

  // outcome
  for (i in 1:N) {
    pO[i] = ao + bso*S[i] + bho*H[i];
  }
  
  O ~ bernoulli_logit(pO);
}
generated quantities {
  real ATCE_H;  // Average direct causal effect of H
  real ATRR_H;  // Average direct relative risk due to H
  
  {
    real lp0;    // logit of p when H==0
    
    vector[N] p_h0;   // p(O | do(H==0))
    vector[N] p_h1;   // p(O | do(H==1))
    vector[N] rr;    // relative risk
    
    for (i in 1:N) {
      lp0 =  ao + bso*S[i];
      
      p_h0[i] = inv_logit(lp0);
      p_h1[i] = inv_logit(lp0 + bho);
    }
    ATCE_H = mean(p_h1 - p_h0);
    for(j in 1:N) {
      rr[j] = p_h1[j] / p_h0[j];
    }
    ATRR_H = mean(rr);
  }
}
