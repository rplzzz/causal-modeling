data {
  int<lower=0> N;
  real us[N];
  int<lower=1, upper=3> ADM[N];
}

transformed data {
  int zero[3];
  int ADMx[N,3];
  vector[3] totalcount;
  vector[3] a0;

  for(j in 1:3) {
    zero[j] = 0;
    totalcount[j] = 0;
  }
  
  for(i in 1:N) {
    ADMx[i] = zero;
    ADMx[i, ADM[i]] = 1;
  }

  for(i in 1:N) {
    totalcount[ADM[i]] += 1;
  }
  for(j in 1:3) {
    a0[j] = logit(totalcount[j] / N);
  }
  for(j in 1:3) {
    // Adding a constant to all values of alpha leaves the model unchanged
    a0[j] -= a0[3];
  }
  print("a0: ", a0);

}

parameters {
  vector[3] alpha;
  vector[3] beta;
}

model {
  alpha ~ normal(a0, 0.25);
  beta ~ normal(0, 0.5);
  // peg the third (ED) entry (technically we should exclude them from the priors
  // above, but this will be fine)
  alpha[3] ~ normal(a0[3], 0.1);
  beta[3] ~ normal(0, 0.1);

  for(i in 1:N) {
    vector[3] theta;
    for(j in 1:3) {
      theta[j] = alpha[j] + beta[j] * us[i];
    }
    ADMx[i] ~ multinomial_logit(theta);
  }
}
