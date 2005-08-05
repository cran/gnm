\name{vcov.gnm}
\alias{vcov.gnm}
\title{ Variance-covariance matrix for 
  parameters in a generalized nonlinear model }
\description{
  This method extracts or computes a variance-covariance matrix for
  use in approximate inference on estimable parameter combinations in a
  generalized nonlinear model.  
}
\usage{
\method{vcov}{gnm}(object, dispersion = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{ a model object of class \code{gnm}. }
  \item{dispersion} {the dispersion parameter for the fitting family. By
    default it is obtained from \code{object}. }
  \item{\dots}{ as for \code{\link{vcov}}. }
}
\details{
  The resultant matrix does not itself necessarily
  contain variances and covariances, since \code{gnm} typically works
  with over-parameterized model representations in which parameters are
  not all identified.  Rather, the resultant matrix is to be used as
  the kernel of quadratic forms which are the variances or
  covariances for estimable parameter combinations.
 
  The matrix values are scaled by \code{dispersion}. If the dispersion
  is not specified, it is taken as \code{1} for the \code{binomial} and
  \code{Poisson} families, and otherwise estimated by the residual
  Chi-squared statistic divided by the residual degrees of freedom. The
  dispersion used is returned as an attribute of the matrix.
}
\value{
  A square matrix, with number of rows/columns equal to
  \code{length(coef(object))}.
}
\references{ Turner, H and Firth, D (2005). Generalized nonlinear models
in R: An overview of the gnm package.  At \url{http://cran.r-project.org}}
\author{ David Firth }
\note{ The \code{gnm} class includes generalized linear models, and it
  should be noted that the
  behaviour of \code{vcov.gnm} differs from that of
  \code{\link{vcov.glm}} whenever \code{any(is.na(coef(object)))} is
  \code{TRUE}.  Whereas \code{vcov.glm} drops all rows and columns which
  correspond to \code{NA} values in \code{coef(object)}, \code{vcov.gnm}
  keeps those columns (which are full of zeros, since the \code{NA}
  represents a parameter which is fixed either by use of the
  \code{constrain} argument to \code{gnm} or by a convention to handle
  linear aliasing). 
}
\seealso{ \code{\link{getContrasts}}, \code{\link{se}} }
\examples{
set.seed(1)
data(yaish)
## Fit the "UNIDIFF" mobility model across education levels
unidiff <- gnm(Freq ~ educ:orig + educ:dest +
               Mult(Exp(-1 + educ), orig:dest), family = poisson,
               data = yaish)
## Examine the education multipliers (differences on the log scale):
ofInterest <- grep("Mult1.Factor1", names(coef(unidiff)))
educMultipliers <- getContrasts(unidiff, rev(ofInterest))[[1]]
## Now get the same standard errors using a suitable set of
## quadratic forms, by calling vcov() directly:
cmat <- contr.sum(ofInterest)
sterrs <- sqrt(diag(t(cmat)
                     \%*\% vcov(unidiff)[ofInterest, ofInterest]
                     \%*\% cmat))
all(sterrs == (educMultipliers$SE)[-1]) ## TRUE
}
\keyword{ models }
\keyword{ regression }
\keyword{ nonlinear }