more <- function() {

  if (!has_more()) {
    rlang::inform("No error information has been saved for more() yet.")
    return(invisible(NULL))
  }
  more_info <- get_more_info()

  # TODO if more_info$message is path then open that file
  # TODO support vim style paths for row/col spec
  # TODO option to open files in console with file.show()
  cat(more_info$message)

  if (is.null(more_info$data)) {
    return(invisible(NULL))
  }

  cli::cli_h2("data")
  print(more_info$data)
  invisible(more_info$data)

}
