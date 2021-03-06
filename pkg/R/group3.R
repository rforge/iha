#'Calculate the group 3 IHA parameters.
#'
#'The group 3 IHA parameters measure the timing of annual extreme water conditions.
#'These metrics will differ from TNC metrics where the minimum or maximum occurs during a leap year after
#'february 28th.  The TNC software seems to assume that all years are leap years.
#'So if the minium for a year is Mar 1 of a non-leap year, this code will return 60,
#'whereas the TNC sofware returns 61.
#'
#'@inheritParams group5
#'@param mimic.tnc should the function perform the calculation like the TNC IHA software?
#'@return a matrix of the group 3 parameters
#'@author jason.e.law@@gmail.com
#'@references \url{http://www.conservationgateway.org/Files/Pages/indicators-hydrologic-altaspx47.aspx}
#'@importFrom lubridate yday year
#'@export
#'@examples
#'data(bullrun)
#'group3(bullrun, 'water')
#'
`group3` <- function (x, year = c('water', 'calendar'), mimic.tnc = F){
  ihaRange <- function(x, mimic.tnc){
    if (mimic.tnc){
      return(yday2(which.range.zoo(x)))
    } else {
      return(yday(c(which.range.zoo(x))))
    }
  }
  stopifnot(is.zoo(x))
  year <- match.arg(year)
  yr <- switch(year,
               water = water.year(index(x)),
               calendar = year(index(x)))
  sx <- split(x, yr)

  res <- sapply(sx, ihaRange, mimic.tnc = mimic.tnc)
  dimnames(res)[[1]] <- c("Min", "Max")
  return(t(res))
}
