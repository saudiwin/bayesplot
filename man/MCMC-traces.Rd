% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mcmc-traces.R
\name{MCMC-traces}
\alias{MCMC-traces}
\alias{mcmc_trace}
\alias{mcmc_trace_highlight}
\title{Traceplot (time series plot) of MCMC draws}
\usage{
mcmc_trace(x, pars = character(), regex_pars = character(),
  transformations = list(), facet_args = list(), ..., n_warmup = 0,
  window = NULL, size = NULL, divergences = NULL)

mcmc_trace_highlight(x, pars = character(), regex_pars = character(),
  transformations = list(), facet_args = list(), ..., n_warmup = 0,
  window = NULL, size = NULL, alpha = 0.2, highlight = 1)
}
\arguments{
\item{x}{A 3-D array, matrix, list of matrices, or data frame of MCMC draws.
The \link{MCMC-overview} page provides details on how to specify each these
allowed inputs.}

\item{pars}{An optional character vector of parameter names. If neither
\code{pars} nor \code{regex_pars} is specified then the default is to use
\emph{all} parameters.}

\item{regex_pars}{An optional \link[=grep]{regular expression} to use for
parameter selection. Can be specified instead of \code{pars} or in addition
to \code{pars}.}

\item{transformations}{Optionally, transformations to apply to parameters
before plotting. If \code{transformations} is a function or a single string
naming a function then that function will be used to transform all
parameters. To apply transformations to particular parameters, the
\code{transformations} argument can be a named list with length equal to
the number of parameters to be transformed. Currently only univariate
transformations of scalar parameters can be specified (multivariate
transformations will be implemented in a future release). If
\code{transformations} is a list, the name of each list element should be a
parameter name and the content of each list element should be a function
(or any item to match as a function via \code{\link{match.fun}}, e.g. a
string naming a function). If a function is specified by its name as a
string (e.g. \code{"log"}), then it can be used to construct a new
parameter label for the appropriate parameter (e.g. \code{"log(sigma)"}).
If a function itself is specified (e.g. \code{log} or \code{function(x)
log(x)}) then \code{"t"} is used in the new parameter label to indicate
that the parameter is transformed (e.g. \code{"t(sigma)"}).}

\item{facet_args}{Arguments (other than \code{facets}) passed to
\code{\link[ggplot2]{facet_wrap}} to control faceting.}

\item{...}{Currently ignored.}

\item{n_warmup}{An integer; the number of warmup iterations included in
\code{x}. The default is \code{n_warmup = 0}, i.e. to assume no warmup
iterations are included. If \code{n_warmup > 0} then the background for
iterations \code{1:n_warmup} is shaded gray.}

\item{window}{An integer vector of length two specifying the limits of a
range of iterations to display.}

\item{size}{An optional value to override the default line size (if calling
\code{mcmc_trace}) or the default point size (if calling
\code{mcmc_trace_highlight}).}

\item{divergences}{For models fit using \code{\link{NUTS}} (more generally,
any \href{http://en.wikipedia.org/wiki/Symplectic_integrator}{symplectic
integrator}), an optional vector or data frame providing information about
divergent transitions. If a data frame is provided it should be an object
returned by \code{\link{nuts_params}} (or an object with the same
structure). If a vector is provided it should be a vector with one element
per iteration, with each element either \code{0} (no divergence) or
\code{1} (a divergence in at least one chain). If \code{divergences} is
specified then red tick marks are added to the bottom of the traceplot
indicating within which iterations there was a divergence. See the end of
the \strong{Examples} section, below.}

\item{alpha}{For \code{mcmc_trace_highlight}, passed to
\code{\link[ggplot2]{geom_point}} to control the transparency of the points
for the chains not highlighted.}

\item{highlight}{For \code{mcmc_trace_highlight}, an integer specifying one
of the chains that will be more visible than the others in the plot.}
}
\value{
A ggplot object that can be further customized using the
  \pkg{ggplot2} package.
}
\description{
Traceplot of MCMC draws. See the \strong{Plot Descriptions} section, below,
for details.
}
\section{Plot Descriptions}{

\describe{
  \item{\code{mcmc_trace}}{
   Standard traceplots of MCMC draws. For models fit using \code{\link{NUTS}}
   the \code{divergences} argument can be used to also show divergences on
   the traceplot.
  }
  \item{\code{mcmc_trace_highlight}}{
   Traces are plotted using points rather than lines and the opacity of all
   chains but one (specified by the \code{highlight} argument) is reduced.
  }
}
}

\examples{
# some parameter draws to use for demonstration
x <- example_mcmc_draws(chains = 4, params = 6)
dim(x)
dimnames(x)

# traceplots of the betas
color_scheme_set("viridis")
mcmc_trace(x, regex_pars = "beta")
\donttest{
color_scheme_set("viridisA")
mcmc_trace(x, regex_pars = "beta")

color_scheme_set("viridisC")
mcmc_trace(x, regex_pars = "beta")
}

# mix color schemes
color_scheme_set("mix-blue-red")
mcmc_trace(x, regex_pars = "beta")

# use traditional ggplot discrete color scale
mcmc_trace(x, pars = c("alpha", "sigma")) +
 ggplot2::scale_color_discrete()

# zoom in on a window of iterations, increase line size,
# add tick marks, move legend to the top, add gray background
color_scheme_set("viridisA")
mcmc_trace(x[,, 1:4], window = c(100, 130), size = 1) +
  panel_bg(fill = "gray90", color = NA) +
  legend_move("top")

\dontrun{
# parse facet label text
color_scheme_set("purple")
p <- mcmc_trace(
  x,
  regex_pars = "beta\\\\[[1,3]\\\\]",
  facet_args = list(labeller = ggplot2::label_parsed)
)
p + facet_text(size = 15)

# mark first 100 draws as warmup
mcmc_trace(x, n_warmup = 100)

# plot as points, highlighting chain 2
color_scheme_set("brightblue")
mcmc_trace_highlight(x, pars = "sigma", highlight = 2, size = 2)

# for models fit using NUTS divergences can be displayed in the traceplot
library("rstanarm")
fit <- stan_glm(mpg ~ ., data = mtcars,
  # next line to keep example fast and also ensure we get some divergences
                prior = hs(), iter = 400, adapt_delta = 0.8)

# extract draws using as.array (instead of as.matrix) to keep
# chains separate for traceplot
posterior <- as.array(fit)

# for stanfit and stanreg objects use nuts_params() to get the divergences
mcmc_trace(
  posterior,
  pars = "sigma",
  divergences = nuts_params(fit) # or nuts_params(fit, pars = "divergent__")
)
}

}
\seealso{
Other MCMC: \code{\link{MCMC-combos}},
  \code{\link{MCMC-diagnostics}},
  \code{\link{MCMC-distributions}},
  \code{\link{MCMC-intervals}}, \code{\link{MCMC-nuts}},
  \code{\link{MCMC-overview}}, \code{\link{MCMC-recover}},
  \code{\link{MCMC-scatterplots}}
}
