% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DPMGibbsSkewN_EB.R
\name{DPMGibbsSkewN_EB}
\alias{DPMGibbsSkewN_EB}
\title{Slice Sampling of Dirichlet Process Mixture of skew Normals}
\usage{
DPMGibbsSkewN_EB(z, hyperG0, a, b, N, doPlot = TRUE, plotevery = 1,
  diagVar = TRUE, ...)
}
\arguments{
\item{z}{data matrix \code{d x n} with \code{d} dimensions in rows 
and \code{n} observations in columns.}

\item{hyperG0}{prior mixing distribution.}

\item{a}{shape hyperparameter of the Gamma prior 
on the parameter of the Dirichlet Process.}

\item{b}{scale hyperparameter of the Gamma prior 
on the parameter of the Dirichlet Process.}

\item{N}{number of MCMC iterations.}

\item{doPlot}{logical flag indicating wether to plot MCMC iteration or not.
Default to \code{TRUE}.}

\item{diagVar}{logical flag indicating wether the variance of each cluster is 
estimated as a diagonal matrix, or as a full matrix. 
Default is \code{TRUE} (diagonal variance).}

\item{nbclust_init}{number of clusters at initialisation. 
Default to 30 (or less if there are less than 30 observations).}
}
\value{
a object of class \code{DPMclust} with the following attributes: 
 \itemize{
     \item{\code{mcmc_partitions}:}{a list of length \code{N}. Each
      element \code{mcmc_partitions[n]} is a vector of length 
      \code{n} giving the partition of the \code{n} observations.}
     \item{\code{alpha}:}{ a vector of length \code{N}. \code{cost[j]} is the cost 
associated to partition \code{c[[j]]}}
     \item{\code{weights_list}:}{}
     \item{\code{logposterior_list}:}{}
     \item{\code{data}:}{the data matrix \code{d x n} with \code{d} dimensions in rows 
and \code{n} observations in columns.}
     \item{\code{nb_mcmcit}:}{the number of MCMC itertations}
 }
}
\description{
Slice Sampling of Dirichlet Process Mixture of skew Normals
}
\examples{
rm(list=ls())
library(ggplot2)

#Number of data
n <- 2000
set.seed(123)
set.seed(1234)
#set.seed(4321)


d <- 2
ncl <- 4

# Sample data

sdev <- array(dim=c(d,d,ncl))

xi <- matrix(nrow=d, ncol=ncl, c(-1.5, 1, 1.5, 1, 1.5, -2, -2, -2))
psi <- matrix(nrow=d, ncol=4, c(0.4, -0.6, 0.8, 0, 0.3, -0.7, -0.3, -1.2))
p <- c(0.2, 0.1, 0.4, 0.3) # frequence des clusters
sdev[, ,1] <- matrix(nrow=d, ncol=d, c(0.3, 0, 0, 0.3))
sdev[, ,2] <- matrix(nrow=d, ncol=d, c(0.1, 0, 0, 0.3))
sdev[, ,3] <- matrix(nrow=d, ncol=d, c(0.3, 0.15, 0.15, 0.3))
sdev[, ,4] <- .3*diag(2)


 
c <- rep(0,n)
z <- matrix(0, nrow=d, ncol=n)
for(k in 1:n){
 c[k] = which(rmultinom(n=1, size=1, prob=p)!=0)
 z[,k] <- xi[, c[k]] + psi[, c[k]]*abs(rnorm(1)) + sdev[, , c[k]]\%*\%matrix(rnorm(d, mean = 0, sd = 1), nrow=d, ncol=1)
 cat(k, "/", n, " observations simulated\\n", sep="")
}
 
# Set parameters of G0

priorMix <- list()
priorMix[["weights"]] <- p
priorMix[["parameters"]] <- list()  
for(j in 1:ncl){
 priorMix[["parameters"]][[j]] <- list()
 priorMix[["parameters"]][[j]][["b_xi"]] <- xi[,j]
 priorMix[["parameters"]][[j]][["b_psi"]] <- psi[,j]
 priorMix[["parameters"]][[j]][["lambda"]] <- crossprod(sdev[,,j])
 priorMix[["parameters"]][[j]][["kappa"]] <- 0.001
 priorMix[["parameters"]][[j]][["D_xi"]] <- 1
 priorMix[["parameters"]][[j]][["D_psi"]] <- 1
 priorMix[["parameters"]][[j]][["nu"]] <- d + 0.1
}
 
 # hyperprior on the Scale parameter of DPM
 a <- 0.0001
 b <- 0.0001
 
 # do some plots
 doPlot <- TRUE 
 
 
 
 ## Data
 ########
 p <- (ggplot(data.frame("X"=z[1,], "Y"=z[2,]), aes(x=X, y=Y)) 
       + geom_point()
       + ggtitle("Simple example in 2d data")
       +xlab("D1")
       +ylab("D2")
       +theme_bw())
 p
 
 
 # Gibbs sampler for Dirichlet Process Mixtures
 ##############################################
 MCMCsample_sn_EB <- DPMGibbsSkewN_EB(z, hyperG0=priorMix, a, b, N=1000, doPlot, plotevery=100, gg.add=list(theme_bw()))
 
 s <- summary(MCMCsample_sn, burnin = 500)
 print(s)
 plot(s)
 plot_ConvDPM(MCMCsample_sn, from=2)
 cluster_est_binder(MCMCsample_sn$c_list[50:500])
 
 
 
 




}
\author{
Boris Hejblum
}

