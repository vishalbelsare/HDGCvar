#' @title Test multiple pairs Granger causality in High Dimensional mixed Integrated and Cointegrated VARs
#' @description A wrapper around \code{\link{HDGC_VAR_multiple}}. If GCpairs is used,
#' the function is the same as \code{\link{HDGC_VAR_multiple}}. Alternatively, if a we want to test all combinations between
#' variables in GCto and GCfrom, these can be given directly. See Example.
#' @param  data       the data matrix or object that can be coerced to a matrix.
#' @param  GCpairs it should contain a nested list. The outer list is all the pairs to be considered. See \code{ \link{HDGC_VAR_multiple}}.
#' The inner list contains the GCto and GCfrom vectors needed for \code{\link{HDGC_VAR}}.
#' @param  GCto       all combination variables Granger caused
#' @param  GCfrom     all combination variables Granger causing
#' @param  p          lag length of the VAR
#' @param  d          order of lag augmentation corresponding to suspected max order of integration
#' @param  bound      lower bound on tuning parameter lambda
#' @param  parallel   TRUE for parallel computing
#' @param  n_cores    nr of cores to use in parallel computing, default is all but one
#' @param progress_bar display a progress bar, default is true
#' @param store_selections store the lasso-selected variables, default is false (object can become huge in large systems)
#'
#' @return            LM Chi-square test statistics (asymptotic) and LM F-stats with finite sample correction, with their corresponding p-value.
#' Lasso selections are also given if `store_selections = TRUE` (`NULL` otherwise).
#' @export
#' @examples \dontrun{GCto = list(c("Var 1", "Var 2")); GCfrom = list(c("Var 3", "Var 4", "Var 5"))}
#' \dontrun{HDGC_VAR_multiple_pairs(sample_dataset_I1,GCto,GCfrom,p=2,d=2)
#' }
#' @references Hecq, A., Margaritella, L., Smeekes, S., "Inference in Non Stationary High Dimensional VARs" (2020, check the latest version at https://sites.google.com/view/luca-margaritella )
#' @references Hecq, A., Margaritella, L., Smeekes, S., "Granger Causality Testing in High-Dimensional VARs: a Post-Double-Selection Procedure." arXiv preprint arXiv:1902.10991 (2019).
HDGC_VAR_multiple_pairs <- function(data, GCpairs = NULL, GCto = NULL, GCfrom = NULL,
                                    p = 1, d = 0, bound = 0.5 * nrow(data),
                                    parallel = FALSE, n_cores = NULL, progress_bar = TRUE,
                                    store_selections = FALSE) {
  varnames <- colnames(data)
  K <- ncol(data)

  direct_to_from <- !(is.null(GCto) | is.null(GCfrom))
  if (direct_to_from) {
    if (!is.null(GCpairs)) {
      warning("Conflicting input given. GCpairs takes precedence")
    } else {
      nGCto <- length(GCto)
      nGCfrom <- length(GCfrom)
      GCpairs <- vector("list", length = nGCto * nGCfrom)
      for (i in 1:nGCto) {
        for (j in 1:nGCfrom) {
          GCpairs[[(i - 1) * nGCfrom + j]] <- list(GCto = GCto[[i]], GCfrom = GCfrom[[j]])
        }
      }
    }
  }
  GC_all_pairs <- HDGC_VAR_multiple(data = data, GCpairs = GCpairs, p = p, d = d,
                                    bound = bound, parallel = parallel, n_cores = n_cores,
                                    progress_bar = progress_bar, store_selections = store_selections)

  return(list(tests = GC_all_pairs$tests, selections = GC_all_pairs$selections))
}
