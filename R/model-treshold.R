# ==========================================================================
# Package: Cognitivemodels
# File: model-threshold.R
# Author: Jana B. Jarecki
# ==========================================================================

# ==========================================================================
# Cognitive Model
# ==========================================================================


#' Threshold Model
#' 
#' `treshold()` fits a threshold model with the threshold as free parameter.
#' * `treshold_c()` models continuous responses in form of the distance to a threshold
#' * `treshold_d()` models discrete choices given the distance to a threshold
#' @useDynLib cognitivemodels, .registration = TRUE
#' @eval .param_formula(1)
#' @eval .param_fix("threshold_d")
#' @return A model of class "treshold".
#' 
#' ## Model Parameters
#' * _**`nu`**_: the threshold.
#' * In `treshold_d()`: `r .rd_choicerules()`
#' 
#' @template cm
#' @author Jana B. Jarecki
#' @details Given the formula \code{y ~ a} the model predicts y = 1 for a >= \code{nu} and y = 0 for a < \code{nu}
#' 
#' 
#' @examples 
#' D <- data.frame(
#'        y = rep(0:1, each=5),
#'        a = 1:10)
#' 
#' M <- threshold_c(y ~ a, D, fix="start")        # fixed par. to start values
#' predict(M)                                     # predict dist. to threshold
#' anova(M)                                       # anova-like table
#' summary(M)                                     # summarize
#' 
#' M <- threshold_d(y ~ a, D, fix="start")        # fixed par. to start values
#' predict(M)                                     # predict dist. to threshold
#' anova(M)                                       # anova-like table
#' summary(M)                                     # summarize
#' M$MSE()                                        # mean-squared error   
#' 
#' ### Binary response given a threshold
#' # --------------------------------------------
#' M <- threshold(y ~ a, D, fix="start", choicerule = "softmax")
#' predict(M)                       #  --"--  maximum posterior
#' anova(M)                                       # anova-like table
#' summary(M)                                     # summarize
#' M$MSE()                                        # mean-squared error    
#' 
#' 
#' ### Parameter specification and fitting
#' ----------------------------------------
#' # Use a response variable, y, to which we fit parameter
#' threshold(y ~ a, D, fix = "start", "softmax")     # "start" fixes all par.,
#'                                                   # and fits none 
#' threshold(y ~ a , D, list(nu=2), "softmax")       # fix threshold nu to 2
#' threshold(y ~ a, D, list(tau=0.5), "softmax")     # fix soft-max tau to 1   
#' threshold(y ~ a, D, choicerule = "softmax")       # nu and tau free param   
#' 
#' @export
threshold <- function(formula, data, fix = list(), choicerule = NULL, mode, discount = 0L, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  return(do.call(what = Threshold$new, args = .args, envir = parent.frame()))
}

#' Threshold Model
#' 
#' @rdname threshold
#' 
#' @export
threshold_c <- function(formula, data, fix = list(), choicerule = NULL, discount = 0, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  .args[["mode"]] <- "continuous"
  return(do.call(what = Threshold$new, args = .args, envir = parent.frame()))
}

#' Threshold Model
#' 
#' @rdname threshold
#' 
#' @export
threshold_d <- function(formula, data, fix = list(), choicerule = "softmax", discount = 0, options = list(), ...) {
  .args <- as.list(rlang::call_standardise(match.call())[-1])
  .args[["mode"]] <- "discrete"
  .args[["choicerule"]] <- choicerule
  return(do.call(what = Threshold$new, args = .args, envir = parent.frame()))
}


Threshold <- R6Class("Threshold",
  inherit = Cm,
  public = list(
    initialize = function(formula, data = data.frame(), fix = list(), choicerule = NULL, mode, discount = 0, options = list(), ...) {

      super$initialize(
        title = "Threshold",
        formula = formula,
        data = data,
        parspace = self$make_parspace(f=formula, d=data),
        choicerule = choicerule,
        mode = mode,
        fix = fix,
        discount = discount,
        options = c(options, list(solver = c("solnp"))),
        ...)
    },
    make_prediction = function(type, input, ...) {
      type <- match.arg(type, c("response"))
      par <- self$get_par()
      return(input - par["nu"])
    },
    make_parspace = function(f, d) {
      nu_range <- range(super$get_input(f = f, d = d))
      return(make_parspace(nu = c(nu_range, mean(nu_range), NA)))
    },
    check_input = function() {
      # This function is called automatically at the end of initialize()
      # Write code for checking inputs (= data of the RHS of formula) below

      # -----------------
      super$check_input() # leave this at the end, it runs background checks
    }
  )
)
