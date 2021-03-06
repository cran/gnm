\name{termPredictors}
\alias{termPredictors}
\title{ Extract Term Contributions to Predictor }
\description{
  \code{termPredictors} is a generic function which extracts the
  contribution of each term to the predictor from a fitted model object.  
}
\usage{
termPredictors(object, ...)
}
\arguments{
  \item{object}{ a fitted model object. }
  \item{\dots}{ additional arguments for method functions.  }
}
\details{
  The default method assumes that the predictor is linear and calculates
  the contribution of each term from the model matrix and fitted
  coefficients. A method is also available for \code{\link{gnm}} objects.
}
\value{
  A matrix with the additive components of the predictor in labelled columns.
}
\author{ Heather Turner }

\seealso{ \code{\link{gnm}} }
\examples{
## Linear model
G <- gl(4, 6)
x <- 1:24
y <- rnorm(24, 0, 1)
lmGx <- lm(y ~ G + x)
contrib <- termPredictors(lmGx)
contrib
all.equal(as.numeric(rowSums(contrib)), as.numeric(lmGx$fitted)) #TRUE

## Generalized linear model
y <- cbind(rbinom(24, 10, 0.5), rep(10, 24))
glmGx <- glm(y ~ G + x, family = binomial)
contrib <- termPredictors(glmGx)
contrib
all.equal(as.numeric(rowSums(contrib)),
          as.numeric(glmGx$linear.predictors)) #TRUE

## Generalized nonlinear model
A <- gl(4, 6)
B <- gl(6, 1, 24)
y <- cbind(rbinom(24, 10, 0.5), rep(10, 24))
set.seed(1)
gnmAB <- gnm(y ~ A + B + Mult(A, B), family = binomial)
contrib <- termPredictors(gnmAB)
contrib
all.equal(as.numeric(rowSums(contrib)),
          as.numeric(gnmAB$predictors)) #TRUE
}

\keyword{ models }
\keyword{ regression }
