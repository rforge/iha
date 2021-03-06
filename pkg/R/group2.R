#'Calculates the group2 IHA statistics
#'
#'The group 2 statistics measure the magnitude of monthly water condition and
#'include 12 parameters.
#'
#'@inheritParams group5
#'@param mimic.tnc should the function perform the calculation like the TNC IHA software?
#'@param ... additional arguments passed to ddply
#'@return a data frame with the group 2 statistics for each year
#'@author jason.e.law@@gmail.com
#'@references \url{http://www.conservationgateway.org/Files/Pages/indicators-hydrologic-altaspx47.aspx}
#'@importFrom plyr ddply '.'
#'@importFrom zoo coredata index
#'@importFrom lubridate year
#'@export
#'@examples
#'data(bullrun)
#'group2(bullrun, 'water')
#'
'group2' <- function(x, year = c('water', 'calendar'), mimic.tnc = T, ...){
  stopifnot(is.zoo(x))
  year <- match.arg(year)
  yr <- switch(year,
               water = water.year(index(x)),
               calendar = year(index(x)))
  rollx <- runmean.iha(x, year = yr, mimic.tnc = mimic.tnc)
  xd <- cbind(year = yr, as.data.frame(rollx))
	res <- ddply(xd, .(year), function(x) group2Funs(x[,-1]), ...)
	return(res)
}

#'Calculate rolling means for group2 statistics
#'
#'Calculate rolling means four group2 statsistics.  Uses runmean from caTools
#'@param x a numeric vector
#'@param year a vector of year (calendar or water year identifiers; necessary 
#'for mimic.tnc = T
#'@param mimic.tnc logical should the years be split before the running mean is 
#'calculated
#'@importFrom caTools runmean
#'@export
runmean.iha <- function(x, year = NULL, mimic.tnc = F){
  window <- c(1, 3, 7, 30, 90)
  vrunmean <- Vectorize(runmean, vectorize.args = 'k')
  if (mimic.tnc){
    sx <- split(coredata(x), year)
    rollx <- lapply(sx, vrunmean, k = window, alg = 'fast', endrule = 'NA')
    rollx <- do.call('rbind', rollx)
  } else {
    rollx <- vrunmean(coredata(x), k = window, alg = 'fast', endrule = 'NA')
  }
  colnames(rollx) <- sprintf('w%s', window)
  return(rollx)
}

#'Calculates group2 statistics from a matrix of rolling means
#'
#'Calculates group2 statistics from a matrix of rolling means
#'@param x a matrix of rolling means
#'@export
group2Funs <- function(x){
  rng <- as.numeric(apply(x, 2, range, na.rm=T))
  baseindex <- min(x[,3], na.rm = T) / mean(x[,1], na.rm = T)
  zeros <- length(which(x[,1] == 0))
  ans <- c(rng, zeros, baseindex)
  nms <- sprintf(c('%1$s Day Min', '%1$s Day Max'), rep(c(1, 3, 7, 30, 90), each=2))
  names(ans) <- c(nms, 'Zero flow days', 'Base index')
  ans
}
