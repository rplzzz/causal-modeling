## Datasets 1-6

Various unsatisfactory experiments

## Dataset 7

Two demographic variables, S and H.  S has no effect on outcome (O).
H has a direct effect, and an indirect effect mediated by an
unobserved SES.  The dataset contains three proxies for SES.  D is a
binary variable, 1 if SES is below a threshold, 0 if SES is above it.
I0 is a low-variance approximation to SES.  I is a high-variance
approximation to SES.

The direct effect of H on O in this model is modest.  The baseline
probability of a bad outcome is about 9% (log-odds of -2.3).  The
direct effect of H is to increase the log-odds by 0.2, which by itself
ups the probability to about 10%.  The total effect increases the
log-odds by 0.45 (on average), for a total probability of 13.5%.

### Experiments

  0. Logistic regression controlling for S and H.  Gives the total
     causal effect of H.  
  1. Logistic regression pretending that SES is observed and
     controlling for it.  
  2. Logistic regression controlling for the low-variance proxy for
     SES.  
  3. Logistic regression controlling for the high-variance proxy for
     SES.  
  4. Imputing values for SES using I and D, and controlling on the
     imputed values.  
  5. Imputing values for SES using D alone, and controlling on the
     imputed values.  
  6. Imputing values for SES using I alone, and controlling on the
     imputed values.  

### Results

  0. Good sampling, gives the total causal effect.  
  1. Good sampling.  Reproduces features of the simulation model
     almost perfectly (as expected).  The threshold for D in the
     simulation manifests as a coefficient between SES and D of 11.9,
     an exceptionally large value for a logistic regression.  The
     posterior distribution for the direct effect of H on O is
     centered on the correct value, but is surprisingly wide,
     illustrating binary variables' weakness at constraining model
     parameters.  
  2. Results nearly identical to model 7.1, as expected.
  3. Good sampling.  The strength of the direct effect is biased a
     little high, with a corresponding low bias in the strength of the
     indirect effect.  **Conclusion:** _Using the high-variance proxy
     as if it were identical to the unknown value appears to produce
     unsatisfactory
     results._  
  4. Good sampling.  Results for H direct and indirect effects on O
     were very close to model 7.1.  Other than being a little slow to
     sample, this model exceeded my expectations.  It's interesting to
     note what it didn't get right.  The coefficient between SES and D
     is "only" 4.7, indicating that this model is not able to see the
     SES threshold for D as clearly as 7.1 (no surprise there).  In
     light of this I would conjecture that D is not providing much
     information for constraining SES.  The estimate of the variance
     of I around SES was also a bit low.  **Conclusion:** _This appears
     to be the best model using only realistically measured data._
  5. Poor sampling.  The highest R-hat was only 1.02, but the sampling
     traces looked visibly off.  The results are kind of a disaster.
     The sign of the direct effect is wrong, though the indirect
     effect is larger to compensate.  I'm not really convinced that
     this model even sampled correctly.  Either way, it seems like a
     binary observation alone isn't enough to constrain the unobserved
     variable.
  6. Mostly good sampling, though maybe a little questionable for the
     parameter for the variance between SES and I (R-hat was 1.02, and
     the traces looked a little ratty, though not as bad as the traces
     in m7.5).  Results were close to m7.4, seemingly supporting the
     conjecture that the binary variable D isn't really adding any
     useful information about SES.  

## Dataset 8

Like Dataset 7, execpt we have added an admission status, which can be
either OSH (1), Elective (2), or ED (3).  OSH has a positive effect on
P(O=1), Elective has a strong negative effect, and ED is neutral.  The
baseline admission type probabilities are 20/10/70, with higher SES
enhancing Elective and depressing OSH.

The questions we are trying to answer with this dataset are:  
  1. Does this additional form of mediated dependence affect our
     ability to separate the direct and indirect causal effects of H?
  2. Does the admission status provide any useful constraint on SES?
     We know that D didn't, but perhaps the problem there was the hard
     threshold.
	 
### Experiments
 
Where possible these experiments are numbered to correspond with their
counterparts in Dataset 7; therefore, some numbers may be skipped if
the results from 7 suggest that the experiment isn't worth
running.  
 
  0. Logistic regression on S and H to get the total causal effect.
  1. Logistic regression on S, H, and SES (normally unobserved),
     including the effect of SES on ADM.
  4. Impute SES using I and D, but ignore the link to ADM.  (However,
     we still include the effects of ADM on outcome).
  7. Impute SES using I, D, and ADM.  Include effects of ADM on
     outcome.
  
### Results

  0. Good sampling.  The most surprising thing in this experiment was
     that adding the effect of OSH on outcomes and the effect of SES
     on OSH really doesn't produce a measurable change in the total
     causal effect of H.  The best explanation I can come up with is
     that the causal chain is just too tenuous.  The (simulation
     model) effect of H on SES is just 0.5 std. dev, and increasing
     the strength of the SES effect on ADM equally affects H=1 and H=0
     cases with low SES.  The practical upshot is that in the sample,
     24% of H=1 cases were OSH, vs. 20% of H=0 cases.  
	 
	 If this were the only connection between H and O, we would
     probably see some appreciable risk here, but in presence of other
     risk factors, the effect of cranking up the strength of ADM->O is
     actually to increase the base rate of O=1, making other causal
     pathways less important.  
	 
	 In light of these results, we still need to see whether leaving
     out the SES->ADM connection results in bias, and we should check
     to make sure that in the absence of other causal pathways from H
     to O, the H->ADM connection still creates some risk (e.g., what
     if buo = 0?)  
  1. We ran this one in response to the effect of SES on ADM not being
     identifiable in 8.7.  These results seem to confirm that
     finding.  The posterior pdfs on the coefficients for the SES
     effect on ADM are essentially the same as the priors.  
  4. Good sampling.  Accurate value for bho, and comparable estimates
     of the direct contribution of H to relative risk.
     Unsurprisingly, the model also recovered the effect of admission
     status on outcome reasonably well.  
  7. Good sampling despite some issues at the beginning of the run.
     Results for the causal effect of H were nearly identical to model
     8.4.  One notable result is that the model was unable to
     meaningfully constrain the effect of SES on admission status.
     The 95% CI for the effect on the logit value for OSH is -0.96 -
     +0.99, which is pretty much the 95% CI for the prior (the actual
     value was -0.3).  This result motivated us to go back and look at
     the "truth" model including the ground truth for the unobserved
     SES, so that we can see if this is due to the noise in the
     indicator masking this effect, or if it's just that effects on
     multinomial variables are hard to tease out.
	 
## Dataset 7A

Same structure as dataset 7, but the coefficient for the effect of SES
on outcome is set to 0, with ao adjusted to give the same overall
mortality rate.  In this case we should get a total effect equal to
the direct effect.

### Experiments

  0. Total causal effect.
  1. Direct causal effect, controlling for the unobserved SES.
  
### Results

  0. Total relative risk was 1.20, which is very nearly the same as the
     direct relative risk from Dataset 7.  
  1. Direct relative risk came out to 1.21, making the difference
     between the total and direct risk well within the expected
     statistical fluctuation.

## Dataset 7B

Same structure and coefficients as dataset 7, except that S is
slightly positively associated with SES and negatively associated with
O.  Analyzing this dataset with S omitted should produce a biased
estimate for bho, even when you control for SES.  The numbering of
these experiments doesn't line up with the other Dataset 7 variants,
and since none of them involve imputing SES values, I just ran them
all with glm (so, no corresponding runmod or stan files).

For this set of parameters, omitting S (i.e., O ~ uSES + H) roughly
doubles the estimate of the coefficient on H, badly overestimating the 

### Experiments

  1. Total causal effect of H, controlling for S.
  2. Total causal effect of H, omitting S.
  3. Direct causal effects, controlling for S, H, and SES.
  4. Direct causal effect of H, omitting S from the model.
  
### Results

  1. bso = -0.3, bho = 0.49, ATRR_H = 1.6
  2. bho = 0.50, ATRR_H = 1.6.  No bias in this case because we are
     not controlling for SES.
  3. bso = -0.18 (true value was -0.2), bho = 0.26 (true was 0.2), buo
     = -0.49 (ture was -0.5).  ATRR_H = 1.26 (value with true bho:
     1.19).  The value of bho is off by enough to be mildly
     concerning, but the std. error (1-sigma) on it is 0.06, so we're
     actually not that far off.
  4. 
  
## Dataset 7C

Same as Dataset 7, but with a different RNG seed.  The purpose of this
experiment is to see whether the consistently slightly high values for
bho we see in the other experiments are evidence of bias, or a result
of commonalities in the datasets that were all generated from the same
seed.


  
### 

## Dataset 8A

Same structure as dataset 7, but the coefficient for the effect of SES
on outcome is set to 0, with a0 adjusted to give the same overall
mortality rate.  The effect of SES on admission status is allowed to
operate normally.  The purpose here is to investigate whether the
indirect path through SES and ADM produces an indirect effect when the
other indirect effect pathway is closed.

For H=0 we have 20.5% OSH, 10.9% Elective, while for H=1 we have 23.8%
OSH, 9.7% elective.  Mortality is 15.6% for OSH, vs. 3.4% for elective
and 10.5% for ED.  So, H=1 definitely produces more OSH, and OSH
definitely produces more mortality; however, it remains to be seen if
the two of these together produce a measurable indirect effect.


### Experiments

  0. Total causal effect, calculated in the usual way.
  1. Direct causal effect, controlling for the unobserved SES.
  
### Results

  0. Total relative risk of 1.21, nearly identical to 7A.
  1. Direct relative risk of 1.21, also nearly identical to 7A.  
  
## Dataset 8B

Same structure as dataset 8A, but this time the direct effect is also
set to zero.  Basically, we're trying to see if there is any
detectable effect through the admission mediator.

### Experiments

  0. Total causal effect, as usual.
  
### Results

  0. Total relative risk of 1.02 +/- 0.1.  Definitely too small to
     measure.  

