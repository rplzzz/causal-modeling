// Concordance model 8.4: Impute SES using the low-quality proxy, medicaid status, and ADM.
functions {
  real logodds(data int [] X, data int N) {
    real Nx = sum(X);
    real px = Nx / N;

    print("\tNx: ", Nx, " px: ", px, " logit(px): ", logit(px)); 
    
    return logit(px);
  }
  
}
data {
  int<lower=1> N;
  int<lower=1> n_adm;
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> O[N];
  int<lower=0, upper=1> D[N];
  int<lower=0, upper=n_adm> adm[N];
  vector[N] I;               
}
transformed data {
  real ao0;
  real ad0;
  int ADMX[N, n_adm];

  print("Calc ao0");
  ao0 = logodds(O, N);  // base rate outcome
  print("Calc ad0");
  ad0 = logodds(D, N);	// base rate medicaid
  print("ad0 = ", ad0);

  for(i in 1:N) {
    for(j in 1:n_adm) {
      ADMX[i,j] = 0;
    }
    ADMX[i,adm[i]] = 1;
  }
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
  real buo;                      // SES effect on outcome.
  real<lower=0> sigus;	       // scale factor for I residuals to the mean SES
  real uSES[N];

  vector[n_adm-1] badmo;	// ADM effects on O.  ED assumed to be baseline

  simplex[n_adm] xaadm;		// base probs for ADM
  vector[n_adm] bua;		// SES effect on ADM probs.
}

transformed parameters {
  vector[n_adm] aadm = log(xaadm);
}

model {
  vector[N] SES_mean;  // latent socioeconomic status
  vector[N] pO;	       // accumulator variable for outcome probability
  vector[N] pD;      // accumulator for other var probabilities.
  
  // priors for all parameters
  bsu ~ normal(0, 0.5);
  bhu ~ normal(0, 0.5);

  bud ~ normal(0, 0.5);
  ad ~ normal(ad0, 0.5);

  ao ~ normal(ao0, 0.5);
  bso ~ normal(0, 0.5);
  bho ~ normal(0, 0.5);
  buo ~ normal(0, 0.5);
  bua ~ normal(0, 0.5);

  badmo ~ normal(0, 0.5);
  //aadm ~ normal(0, 0.5);	// This ends up being approximately equivalent to a dirichlet(5,5,5)
  xaadm ~ dirichlet(rep_vector(5, n_adm));

  sigus ~ exponential(0.5);


  // latent SES variable
  for (i in 1:N) {
    SES_mean[i] = bsu*S[i] + bhu*H[i];
  }
  uSES ~ normal(SES_mean, 1.0);
  I ~ normal(uSES, sigus);
  
  // medicaid: base rate + SES effect.
  for (i in 1:N) {
    pD[i] = ad - bud*uSES[i]; // Effect of higher SES presumed to be negative.
  }
  D ~ bernoulli_logit(pD);

  // effect of SES on admission status
  for (i in 1:N) {
    vector[n_adm] lpadm;

    lpadm = aadm + uSES[i] * bua; // logit for multinomial distribution of ADM[i]
    ADMX[i] ~ multinomial_logit(lpadm);
  }

  
  // outcome
  for (i in 1:N) {
    pO[i] = ao + bso*S[i] + bho*H[i] + buo*uSES[i];
    if(adm[i] < n_adm) {
      pO[i] += badmo[adm[i]];
    }
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
    vector[N] rr;    // relative risk
    
    for (i in 1:N) {
      lp0 = ao + bso*S[i] + buo*uSES[i];
      if(adm[i] < n_adm) {
	lp0 += badmo[adm[i]];
      }
      
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
