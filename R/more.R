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
    cat(more_info$message)
  } else {
    cli::cli_h1("more() information")

    if (rlang::is_string(more_info$message) && file.exists(more_info$message)) {
      if (rstudioapi_installed_available()) {
        rstudioapi::navigateToFile(more_info$message)
      } else {
        edit(file = more_info$message)
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
more_data <- function() {
  more_info <- get_more_info()
  more_info$data
}
