#' @title Test multiple combinations Granger causality in High Dimensional Stationary VARs
#' @description This function is a wrapper around \code{\link{HDGC_VAR_I0}} that allows for multiple combinations to be tested
#' @param data the data matrix or object that can be coerced to a matrix.
#' @param GCpairs it should contain a nested list. The outer list is all the pairs to be considered.
#' The inner list contains the GCto and GCfrom vectors needed for \code{\link{HDGC_VAR_I0}}.
#' @param  p          lag length of the VAR
#' @param  bound      lower bound on tuning parameter lambda
#' @param  parallel   TRUE for parallel computing
#' @param  n_cores    nr of cores to use in parallel computing, default is all but one
#' @param progress_bar display a progress bar, default is true
#' @param store_selections store the lasso-selected variables, default is false (object can become huge in large systems)
#'
#' @return            LM Chi-square test statistics (asymptotic) and LM F-stats with finite sample correction, with their corresponding p-value.
#' Lasso selections are also given if `store_selections = TRUE` (`NULL` otherwise).
#' @export
#' @importFrom parallel makeCluster clusterSetRNGStream clusterExport clusterEvalQ detectCores parSapply stopCluster parLapply
#' @examples \dontrun{GC=list(list("GCto"="Var 1", "GCfrom"="Var 2"),list("GCto"="Var 2", "GCfrom"="Var 3"))}
#' \dontrun{HDGC_VAR_multiple_I0(sample_dataset_I0, GC, p=1 )}
#' @references Hecq, A., Margaritella, L., Smeekes, S., "Granger Causality Testing in High-Dimensional VARs: a Post-Double-Selection Procedure." arXiv preprint arXiv:1902.10991 (2019).
HDGC_VAR_multiple_I0 <- function(data, GCpairs, p = 1, bound = 0.5 * nrow(data),
                                 parallel = FALSE, n_cores = NULL,
                                 progress_bar = TRUE, store_selections = FALSE) {
  if (progress_bar) {
    pbapply::pboptions(type = "txt")
  } else {
    pbapply::pboptions(type = "none")
  }
  if (parallel) {
    if (is.null(n_cores)) {
      n_cores <- detectCores() - 1
    }
    cl <- makeCluster(n_cores, setup_strategy = "sequential")
    clusterSetRNGStream(cl, sample.int(2^20, size = 1))
    clusterExport(cl = cl, Filter(function(x) is.function(get(x, .GlobalEnv)), ls(.GlobalEnv)))
    clusterEvalQ(cl = cl, library(glmnet))

    test_list <- pbapply::pblapply(GCpairs, HDGC_VAR_I0, data = data, p = p, bound = bound,
                           parallel = FALSE, store_selections = store_selections, cl = cl)
    stopCluster(cl)
  } else {
    test_list <- pbapply::pblapply(GCpairs, HDGC_VAR_I0, data = data, p = p, bound = bound,
                        parallel = FALSE, store_selections = store_selections)
  }
  out <- simplify_list(test_list, GCpairs)
  return(out)
}
