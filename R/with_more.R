with_more <- function(err, more_message, more_data = NULL, with_class = "error") {

    handler_args <- list()
    handler_args[[with_class]] <- function(err) {
    new_message <- glue::glue("{err$message}\n{more_notification_message()}")
    err$message <- new_message

    register_more(
      more_message,
      more_data
    )

    # Just re-throw the error with our modified message
    rlang::cnd_signal(err)
  }

  # All this function-list-do.call hoop jumping is just to allow the
  # caller to specify the function class they want to match,
  # and pass that into try_fetch, whilst ensuring we do not evaluate 'err'
  # which will blow up in our face.
  do.call(
    function(...) rlang::try_fetch(err, ...), handler_args
  )

}
