// Test code for bernoulli inference (for comparison to the multinomial version)
data {
  int<lower=1> N;
  vector[N] x;
  array[N] int<lower=0, upper=1> iy;
}

parameters {
  real a;
  real b;
}

model {
  b ~ normal(0, 0.5);
  a ~ normal(0, 0.5);

  for(i in 1:N) {
    real lpy = a + b*x[i];

    iy[i] ~ bernoulli_logit(lpy);
  }
}

