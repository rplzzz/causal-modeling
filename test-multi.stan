// Test code for multinomial distribution inference
data {
  int<lower=1> N;
  int<lower=2> nk;
  vector[N] x;
  array [N] int<lower=1, upper=nk> y;
}

parameters {
  simplex[nk] xa;
  vector[nk] b;
}

transformed parameters {
  vector[nk] a = log(xa);
}

model {
  b ~ normal(0, 0.5);
  xa ~ dirichlet(rep_vector(5, nk));

  for(i in 1:N) {
    array[nk] int IY;			// one-hot representation for y
    vector[nk] lpy;		// logits for influence of x on y.

    for(j in 1:nk) {
      IY[j] = 0;
    }
    IY[y[i]] = 1;

    lpy = a + x[i] * b;
    IY ~ multinomial_logit(lpy);
  }
}


    
