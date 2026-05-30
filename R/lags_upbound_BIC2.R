#' @title Lag length Selection via BIC empirical upper bound
#' @description Selects the lag length p of the VAR using an empirical upper bound: residuals of
#' the diagonalized VAR are used to build the empirical covariance matrix and an approximation of
#' its determinant that uses the matrix trace is employed to be able to select p using Bayesian Information Criterion
#' @param data a dataframe or matrix of the original set of time series forming the VAR
#' @param p_max maximum lag length to consider, default is 10
#' @return  returns the estimated lag length upper bound
#' @examples  lags_upbound_BIC2(sample_dataset_I1, p_max=10)
#' @references Hecq, A., Margaritella, L., Smeekes, S., "Inference in Non Stationary High Dimensional VARs" (2020, check the latest version at https://sites.google.com/view/luca-margaritella )
#' @references Hecq, A., Margaritella, L., Smeekes, S., "Granger Causality Testing in High-Dimensional VARs: a Post-Double-Selection Procedure." arXiv preprint arXiv:1902.10991 (2019).
lags_upbound_BIC2 <- function(data,p_max=10){

  data<-as.matrix(data) #data
  n <- nrow(data)
  K <- ncol(data) #numb of variables
  sigma2 <- matrix(nrow = K, ncol = p_max)
  for (k in 1:K) {
    ylags <- create_lags(data[, k], p = p_max, include.original = TRUE, trim = TRUE) #create p_max lags
    for (p in 1:p_max) {
      res <- ols(ylags[, 1], ylags[, 2:(p + 1)])$resid
      sigma2[k, p] <- mean(res^2)
    }
  }
  sigma_sums <- colSums(sigma2)
  BIC <- log(sigma_sums) + log(n) * (1:p_max) * K / n
  Best <- which.min(BIC)
  return(Best)
}
