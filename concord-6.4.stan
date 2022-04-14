// Concordance model 6.4: Fix the parameters for the admission effect.
//  The theory here is that the effects of HNW and SES are being absorbed into
//  the coefficient for OSH effect.
functions {
  real logodds(data int [] X, data int N) {
    real Nx = sum(X);
    real px = Nx / N;

    print("\tNx: ", Nx, " px: ", px, " logit(px): ", logit(px)); 
    
    return logit(px);
  }
  
  real posh_logit(real logit_osh, real logit_elect, real logit_ed) {
    return inv_logit(logit_osh - (logit_elect + logit_ed));
  }
}
data {
  int<lower=0> N;
  int<lower=1, upper=4> SPEC[N];
  int<lower=1, upper=3> ADM[N];
  int<lower=0, upper=1> W[N];
  int<lower=0, upper=1> S[N];
  int<lower=0, upper=1> H[N];
  int<lower=0, upper=1> C[N];
  int<lower=0, upper=1> O[N];
  int<lower=0, upper=1> D[N];
  vector[N] us;               
}
transformed data {
  real ao0;
  real ad0;
  vector[3] aa0;                // base rate for each type of admission (OSH, elective, ED)
  int ADMx[N,3];	 // one-hot representation of admission status
  vector[3] aao;		// ADM effect on outcome: fixed in this run

  aao[1] = 0.1;
  aao[2] = -1.0;
  aao[3] = 0.0;


  print("Calc ao0");
  ao0 = logodds(O, N);  // base rate outcome
  print("Calc ad0");
  ad0 = logodds(D, N);	// base rate medicaid
  print("ad0 = ", ad0);
  
  for(j in 1:3) {
    int A[N];
    for(i in 1:N) {
      A[i] = (SPEC[i] == 1);
    }
    aa0[j] = logodds(A, N);
  }

  for(i in 1:N) {
    for(j in 1:3) {
      ADMx[i,j] = 0;
    }
    ADMx[i, ADM[i]] = 1;
  }
  
}

parameters {
  vector[4] aspc;		// SPEC effect on concordance
  real bwc;			// weekend effect on concordance

  real bsu;			// sex effect on mean SES
  real<upper=0> bhu;		// HNW effect on mean SES

  real bud;                     // SES effect on medicaid, presumed positive (together with the
                                // sign convention below, this implies higher SES lowers the prob.
                                // of being enrolled in medicaid.
  real ad;			// base rate medicaid
  
  vector[3] bua;		// SES effect on ADM
  vector[3] aadm;

  vector[4] aspo;		// SPEC effect on outcome
  real bwo;			// weekend effect on outcome
  real bco;			// concordance effect on outcome
  real bso;			// sex effect on outcome
  real bho;			// HNW effect on outcome
  real buo;			// SES effect on outcome.  I think this can be assumed to be 1,
                                // since it only appears when multiplied by another parameter, never
                                // by itself.
  real<lower=0> sigus;	       // scale factor for I residuals to the mean SES
}

model {
  vector[N] SES_mean;  // latent socioeconomic status
  vector[N] pO;	       // accumulator variable for outcome probability
  vector[N] ptmp;      // accumulator for other var probabilities.
  
  // priors for all parameters
  aspc ~ normal(0, 0.5);
  bwc ~ normal(0, 0.5);

  bsu ~ normal(0, 0.5);
  bhu ~ normal(0, 0.5);

  bua ~ normal(0, 0.5);
  aadm ~ normal(aa0, 0.25);
  
  bud ~ normal(0, 0.5);
  ad ~ normal(0, 0.25);

  aspo ~ normal(0, 0.5);
  bwo ~ normal(0, 0.5);
  bco ~ normal(0, 0.5);
  bso ~ normal(0, 0.5);
  bho ~ normal(0, 0.5);
  buo ~ normal(0, 0.5);

  sigus ~ exponential(0.5);


  // latent SES variable
  for (i in 1:N) {
    SES_mean[i] = bsu*S[i] + bhu*H[i];
  }
  us ~ normal(SES_mean, sigus);	// Include SES truth value.
  
  // medicaid: base rate + SES effect.
  for (i in 1:N) {
    ptmp[i] = ad0 + ad - bud*SES_mean[i]; // Effect of higher SES presumed to be negative.
    if (is_nan(ptmp[i])) {
      print("NaN val found: SES_mean = ", SES_mean[i], " ad = ", ad, "  ad0 = ", ad0, " bud = ",
	    bud);
    }
  }
  D ~ bernoulli_logit(ptmp);

  // concordance: random effect for specialty, plus weekend effect
  for (i in 1:N) {
    ptmp[i] = aspc[SPEC[i]] + bwc*W[i];
  }
  C ~ bernoulli_logit(ptmp);

  // Admission type
  for(i in 1:N) {
    ADMx[i] ~ multinomial_logit(aadm  + bua*SES_mean[i]);
  }
  
  // outcome
  for (i in 1:N) {
    pO[i] = aspo[SPEC[i]] + bwo*W[i] + bco*C[i] + bso*S[i] + bho*H[i] +
      buo*SES_mean[i] + aao[ADM[i]];
  }
  
  O ~ bernoulli_logit(pO);
}
generated quantities {
  real ADCE_H;  // Average direct causal effect of H
  
  {
    real SES_mean;    // reconstruct SES -- Is it possible to make this a transformed parameter?
    real lp0;    // logit of p when H==0
    
    vector[N] p_h0;   // p(O | do(H==0))
    vector[N] p_h1;   // p(O | do(H==1))
    
    for (i in 1:N) {
      SES_mean = bsu*S[i] + bhu*H[i];
      lp0 =  aspo[SPEC[i]] + bwo*W[i] + bco*C[i] + bso*S[i] + buo*SES_mean + aao[ADM[i]];
      
      p_h0[i] = inv_logit(lp0);
      p_h1[i] = inv_logit(lp0 + bho*H[i]);
    }
    ADCE_H = mean(p_h1 - p_h0);
  }
}
