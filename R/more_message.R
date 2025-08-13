# constructor for verbose messages definded in-line.
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
