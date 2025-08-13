more_notification_message <- function() {
  paste0(
    cli::style_dim("Call "),
    "more()",
    cli::style_dim(" for additional error information..."),
    "\n"
  )
}
