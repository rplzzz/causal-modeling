#### Compare two generalized linear models:  Z -> X -> Y, and the same, but with 
#### U as an additional common cause of X and Y.

rbern_logit <- function(N, x)
{
  logp <- ifelse(x < 0,
                 x - log1p(exp(x)),
                 -log1p(exp(-x)))
  p <- exp(logp)
  rbinom(N, 1, p)
}

a <- 0.5    # direct effect of Z on X
b <- 0.3    # direct effect of X on Y

g1 <- 0.6  # effect of unobserved on X
g2 <- 0.4   # effect of unobserved on Y

## Make all three variables have a total variance of 1
sigz <- 1
sigx <- sqrt(1 - (a^2 + g1^2))
sigy <- sqrt(1 - (b^2 + g2^2))

N <- 1000

set.seed(867-5309)

Z <- rnorm(N)
UX <- rnorm(N)
UY <- rnorm(N)
UXY <- rnorm(N)

X1logit <- a*Z + g1*UX + rnorm(N, sd=sigx)
X1 <- rbern_logit(N, X1logit)
Y1logit <- b*X1 + g2*UY + rnorm(N, sd=sigy)
Y1 <- rbern_logit(N, Y1logit)

X2logit <- a*Z + g1*UXY + rnorm(N, sd=sigx)
X2 <- rbern_logit(N, X2logit)
Y2logit <- b*X2 + g2*UXY + rnorm(N, sd=sigy)
Y2 <- rbern_logit(N, Y2logit)

d1 <- tibble::tibble(z=Z, x=X1, y=Y1)
d2 <- tibble::tibble(z=Z, x=X2, y=Y2)

rxz1 <- glm(x~z, family=binomial, d1)
ryz1 <- glm(y~z, family=binomial, d1)
ryx1 <- glm(y~x, family=binomial, d1)

rxz2 <- glm(x~z, family=binomial, d2)
ryz2 <- glm(y~z, family=binomial, d2)
ryx2 <- glm(y~x, family=binomial, d2)
