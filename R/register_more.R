MORE_ENV <- new.env()
MORE_ENV$mores <- list()

# NOTE Might have multiple mores eventually. For now just one.

register_more <- function(more_message, more_data) {
  MORE_ENV$mores <- list(
    message = more_message,
    data = more_data
  )
}

has_more <- function() {
  length(MORE_ENV$mores) > 0
}

get_more_info <- function() {
  MORE_ENV$mores
}
