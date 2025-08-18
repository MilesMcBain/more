#' Constructor for more messages definded in-line.
#'
#' This is a simple helper for defining messages with a title and body using
#' formatting from `{cli}`.
#'
#' Messages can be any text, so you are not limited to using this function to
#' create them.
#' @param title the title of message
#' @param body the rest of the message
#' @export
more_message <- function(
  title,
  body
) {
  cli::cli_fmt(
    {
      cli::cli_h1(title)
      cli::cli_text(body)
    },
    collapse = TRUE
  )
}
