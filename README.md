
# more

<!-- badges: start -->
<!-- badges: end -->

`more` lets you attach context to errors, warnings or any condition, that can viewed via the `more()` call.

This context may be:

  - detailed explanations
  - data sets that assist with understand the issue

It is inspired by [`rustc`'s detailed error explainations](https://rustc-dev-guide.rust-lang.org/diagnostics.html).

## Installation

You can install the development version of more like so:

``` r
pak::pkg_install("milesmcbain/more")
```

## Motivation

Let's say we are validating some tabular user input. Due to the context, we know that each row in table represents a statistical area. These are identified by human readable names, as well as unqiue numeric codes.

The user has input some rows that contain negative values. What's the nicest possible error we can give them look like?

We might immediate conceive of a message like `Column must not be negative`.

But perhaps we could give them some indication as to how many rows, or even which ones need to be fixed. That way they can have confidence they have addressed the problem before running the code again.

This poses some challenges though. We might try:

```r
rlang::abort(
  glue::glue(
    "Column must not be negative. ",
    "Fix areas {paste0(bad_ids, collapse = ', ' )}"
    )
)
```

```
Error: ! Column must not be negative. Fix areas 303021052, 303021053, 303021054,
303021055, 303021056, 303021057, 303021058, 303021059, 303031060, 303031061,
303031062, 303031063, 303031064, 303031065, 303031066, 303041067, 303041068,
303041069, 303041070, 303041071, 303051072, 303051073, 303051074, 303051075,
303051076, 303061077, 303061078, 303061079, 303061080, 304011081, 304011082,
304011083, 304011084, 304011085 Run `rlang::last_trace()` to see where the error
occurred.

```

But that's not worked out so great really. It's unwieldly even with a relatively small number of rows.

And while codes are nice, the human readable names are what might trigger the user to recognise "Ahah these are all from the same region!" etc. Trying to jam both pieces of information into an parsable error message would be futile.

This is the `more()` alternative:

```r
rlang::abort(
  "Column must not be negative"
) |>
  with_more(
    more_message = more_message(
      title = "Negative values for Supply",
      body = glue::glue(
        "The spatial had negative values for Supply. This has been shown to cause unstable estimates.\n",
        "Negative Supply was permitted in previous releases, so you may still find old configuration that contains negatives. Be careful when copy-pasting model inputs.\n",
        "See dataset `negative_supply_rows`."
      )
    ),
    more_data = list(negative_supply_rows = neg_rows)
  )

```

When the user hits the error they see:

```
Error:
! Column must not be negative
Call more() for additional error information...
Run `rlang::last_trace()` to see where the error occurred.
```

And when they call `more()`:

```
── Negative values for Supply ─────────────────────────────────────
The spatial had negative values for Supply. This has been shown to cause
unstable estimates. Negative Supply was permitted in previous releases, so you
may still find old configuration that contains negatives. Be careful when
copy-pasting model inputs. See dataset `negative_supply_rows`.


── more() data ──

$negative_supply_rows
# A tibble: 34 × 2
    sa2_code sa2_name
       <int> <chr>
 1 303021052 Annerley
 2 303021053 Coorparoo
 3 303021054 Fairfield - Dutton Park
 4 303021055 Greenslopes
 5 303021056 Holland Park
 6 303021057 Holland Park West
 7 303021058 Woolloongabba
 8 303021059 Yeronga
 9 303031060 Eight Mile Plains
10 303031061 Macgregor (Qld)
# ℹ 24 more rows
# ℹ Use `print(n = ...)` to see more rows
```

By default the data isn't assigned anywhere (see option `more_auto_assign_data`).

But it can be captured by assigning form `more()` or the shortcut `more_data()` that skips the error report.

```r
# see everything and save data
more_info <- more()

# skip the error report and get the data
more_info <- more_data()
```

So with that data in hand the user could perhaps move immedately to a solution:

```r
library(dplyr)
library(readr)

row_fixes <-
  more_info$negative_supply_rows |>
  mutate(replacement_value = 0.0001)

spatial_input |>
  left_join(
    row_fixes,
    by = c("sa2_code", "sa2_name")
  ) |>
  mutate(
    Supply = coalesce(replacement_value, Supply)
  ) |>
  select(
    -replacement_value
  ) |>
  write_csv("config/spatial_input.csv")
```

And solved in record time! No need to go looking for and checking those dodgy rows.

To recap to enable this speedy fix, whilst keeping the user in the driving seat, we:

  - Gave a detailed explanation of the issue, bringing in helpful additional context, and anticipating the root cause of the issue.
  - Returned data they could use to solve their problem immediately, without having go hunting for it.

Obviously in this contrived case, the bad rows can be found quite quickly. The user probably still appreciated the context about previous versions though, which there is not really space for in a standard error message.

## Cookbook

`with_more` is flexible, allowing a variety of intersting possibilities for exceptionally helpful errors. Some high level points:

- it can wrap any kind of error, warning, message, or other signal. Not just those in `{rlang}`. Base is fair game too.
- it can display error documentation in a variety of formats, you could:
  - open a help topic
  - view a vignette
  - open a .qmd or .Rmd file


### Open a help topic

### Open an Rmd file


## Options

  - `more_auto_assign_data`: If `TRUE` automatically assign the data payload of `more()` to `.more` in the global environment. `FALSE` by default.
