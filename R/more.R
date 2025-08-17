#' Retrieve more context associated with a condition (error, warning etc.)
#'
#' This function displays any detailed explanation messages and or additonal data
#' sets attached to a condition like an error or warning with [with_more()].
#'
#' Datasets are returned so can be assigned from the return of this function.
#'
#' It is also possible to automatically assign datasets after a `more()` call
#' with option `more_auto_assign_data`, which binds them to `.more` in the
#' global environment.
#'
#' `more()` can be called multiple times if desired. The context returned is
#' always for the last signalled condition that attached context using the
#' [with_more()].
#'
#' `more_data()` is a shortcut that returns the data portion of the attached
#' context, skipping the detailed explanation.
#' @export
more <- function() {

  more_info <- get_more_info()

  # Action varies based on type of thing message is.
  # It can be:
  #  - Some text, so display it in console.
  #  - A function, so run it.
  #  - A file, so open it.
  #    - If we don't have rstudioapi we will just use edit() for now,
  #      although I don't love this because it
  #      may block the return of data until it resolves.
  if (is.character(more_info$message) && !file.exists(more_info$message)) {
    cat(more_info$message, "\n")
  } else {
    cli::cli_h1("more() information")

    if (rlang::is_string(more_info$message) && file.exists(more_info$message)) {
      if (rstudioapi_installed_available()) {
        rstudioapi::navigateToFile(more_info$message)
      } else {
        utils::edit(file = more_info$message)
        # TODO possibly better just to read and output here
      }
    } else if (rlang::is_function(more_info$message)) {
      more_info$message()
    }
  }

  if (is.null(more_info$data)) {
    return(invisible(NULL))
  }

  cli::cli_h2("more() data")
  print(more_info$data)

  if (getOption("more_auto_assign_data", FALSE)) {
    assign(".more", more_info$data, .GlobalEnv)
  }

  invisible(more_info$data)
}

# a shortcut to the data, useful for examples in explanations
#' @rdname more
more_data <- function() {
  more_info <- get_more_info()
  cli::cli_h2("more() data")
  more_info$data
}
