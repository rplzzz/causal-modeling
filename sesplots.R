library(ggplot2)

SES_bymedicaid <- function(stanmod, indata, stat = NULL, maxn=2000)
{
  if(is.character(indata)) {
    indata <- readRDS(indata)
  }
  
  sesvals <- extract(stanmod, pars='SES')$SES
  
  if(!is.null(stat)) {
    sesvals <- matrix(apply(sesvals, 2, stat), nrow=1)
  }
  
  pltdata <-
    dplyr::bind_rows(
      lapply(c(0,1),
             function(dstat) {
               vals <- sesvals[ , indata$D == dstat]
               d <- tibble::tibble(SES=as.vector(vals), medicaid=as.integer(dstat))
               if(nrow(d) > maxn) {
                 d <- dplyr::slice_sample(d, n=maxn)
               }
               d
             }))

  ggplot(pltdata, aes(x=medicaid, y=SES, group=medicaid)) + 
    geom_boxplot() +
    theme_bw()
}

SES_bygroundtruth <- function(stanmod, indata, stat=mean, maxn=2000)
{
  if(is.character(indata)) {
    indata <- readRDS(indata)
  }
  
  sesvals <- extract(stanmod, pars='SES')$SES
  
  if(!is.null(stat)) {
    sesvals <- apply(sesvals, 2, stat)
  }
  else {
    sesvals <- apply(sesvals, 2, sample, size=1)
  }
  
  pltdata <- tibble::tibble(SES_model=sesvals, SES_data = indata$us)
  if(nrow(pltdata) > maxn) {
    pltdata <- dplyr::slice_sample(pltdata, n=maxn)
  }
  
  ggplot(pltdata, aes(x=SES_data, y=SES_model)) +
    geom_point() + 
    theme_bw()
}
