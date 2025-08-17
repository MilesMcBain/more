#' Throw conditions with more context
#'
#' This function sets up additional context, attached to a condition like an error
#' or warning, that can be retrieved with the `more()` call. This includes a
#' detailed error message and optionally some data relevent to the error
#' explanation or error debugging. The user is
#' notified about this availability of this context with a short prompt added as
#' an addendum to the message associated with the signal.
#
#' @param err The expression that signals a condition when evaluated. E.g. a call
#'  to `stop()`, `warning()`, [rlang::abort()], [cli::cli_abort()] etc.
#' @param more_message a reference to the detailed error message to display. Could be:
#'   - A character vector, in which case it is displayed
#'   - A file path, in which case the file is opened in the text editor
#'   - A function, in which case it is run. This could be used to open a help
#'      topic or vignette. It is recommended complex functions that may error are
#'      avoided - as a new error when searching for information on a error would
#'      create a poor user experience.
#' @param more_data optional data to return with the more call. Note print() is
#'  called on the data so be careful with large matrices etc which print a lot
#'  of output. It is recommended to use a name list, such that the names can be
#'  referred to in the error documentation.
#' @param with_class Only attach the more() context and prompt to conditions
#'  bearing this class. Default is 'condition' which is all types of conditions.
#' @param rewrite_call For a selection of base conditions like `simpleError` and
#'  `simpleWarning` the reported origin site of the condition becomes the
#'  internals of `with_more()`. To avoid confusion the reported call is automatically
#'  rewritten to the parent of `with_more`. In some cases this will also be
#'  wrong, for example if the condition is being thrown nested from within another
#'  function. In this case `rewrite_call` can be set to `FALSE` to preserve the
#'  reference to the wrapping function.
#' @param call The call to use to for the call rewrite. The default is
#' `rlang::caller_fun()` which is likely correct in many cases. The default may be
#' incorrect if `with_more` is nested within a helper function. A different call can be supplied for use in this case.
#' Although it's probably easier just to use condition signalling from `{rlang}`
#' e.g. [rlang::abort()] and set up the call correctly per thier documentation. It
#' will not be rewritten by `with_more` in that case.
#' @export
#' @seealso [more()] for retrieval of context.
with_more <- function(err,
                      more_message,
                      more_data = NULL,
                      with_class = "condition",
                      rewrite_call = TRUE,
                      call = rlang::caller_call()) {

  handler_args <- list()
  handler_args[[with_class]] <- function(err) {
    if (!inherits(err, "with_more")) {
      new_message <- glue::glue("{err$message}\n{more_notification_message()}")
      err$message <- new_message
      # We add this class so se won't keep appending our more() message
      # recursively
      class(err) <- c(class(err), "with_more")
    }
    if (inherits(err, c("simpleError", "simpleWarning")) && rewrite_call) {
      err$call <- call
      err
    }

    register_more(
      more_message,
      more_data
    )

    # Just re-throw the error with our modified message
    rlang::cnd_signal(err)
    # return NULL here since otherwise warnings and messages will return the
    # signal passed to cnd_signal - printing the message twice.
    invisible()
  }

  # All this function-list-do.call hoop jumping is just to allow the
  # caller to specify the function class they want to match,
  # and pass that into try_fetch, whilst ensuring we do not evaluate 'err'
  # which will blow up in our face.
  do.call(
    function(...) rlang::try_fetch(err, ...),
    handler_args
  )
}
