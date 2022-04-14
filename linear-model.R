#### Compare two models:  Z -> X -> Y, and the same, but with U as an additional
#### common cause of X and Y.

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

X1 <- a*Z + g1*UX + rnorm(N, sd=sigx)
Y1 <- b*X1 + g2*UY + rnorm(N, sd=sigy)

X2 <- a*Z + g1*UXY + rnorm(N, sd=sigx)
Y2 <- b*X2 + g2*UXY + rnorm(N, sd=sigy)

d1 <- tibble::tibble(z=Z, x=X1, y=Y1)
d2 <- tibble::tibble(z=Z, x=X2, y=Y2)

rxz1 <- lm(x~z, d1)
ryz1 <- lm(y~z, d1)
ryx1 <- lm(y~x, d1)

rxz2 <- lm(x~z, d2)
ryz2 <- lm(y~z, d2)
ryx2 <- lm(y~x, d2)
