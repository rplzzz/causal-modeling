#### Visualize parameter correlations in a stan fit

stancorplot <- function(fit, thresh=0.5) 
{
  cm <- as.data.frame(cor(as.matrix(fit), method='spearman'))
  cm$x <- row.names(cm)
  cm <- tidyr::pivot_longer(cm, -x, names_to='y')
  
  cm$value <- abs(cm$value)
  cm$value <- ifelse(cm$value < thresh, 0, cm$value)
  
  ggplot2::ggplot(cm, ggplot2::aes(x=x,y=y, fill=value)) + 
    ggplot2::geom_tile()
}
