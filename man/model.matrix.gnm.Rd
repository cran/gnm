\name{model.matrix.gnm}
\alias{model.matrix.gnm}
\title{ Local Design Matrix for a Generalized Nonlinear Model  }
\description{
  This method extracts or evaluates a local design matrix for a
  generalized nonlinear model
}
\usage{
\method{model.matrix}{gnm}(object, coef = NULL, ...)
}
\arguments{
  \item{object}{ an object of class \code{gnm}. }
  \item{coef}{ if specified, the vector of (non-eliminated) coefficients
    at which the local design matrix is evaluated.  }
  \item{...}{ further arguments.  }
}
\value{
  If \code{coef = NULL}, the local design matrix with columns
  corresponding to the non-eliminated parameters evaluated at
  \code{coef(object)} (extracted from \code{object} if possible).

  Otherwise, the local design matrix evaluated at \code{coef}.
}
\author{ Heather Turner }
\seealso{ \code{\link{gnm}}, \code{\link{model.matrix}} }
\examples{
example(mentalHealth)
model.matrix(RC1model)
model.matrix(RC1model, coef = seq(coef(RC1model)))
}
\keyword{ models }
\keyword{ regression }
\keyword{ nonlinear }
