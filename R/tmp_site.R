

#' Custom site generator to render in /tmp
#'
#' To render your R Markdown documents in \code{/tmp}, you need to add a file
#' \code{index.Rmd} that specifies \code{site: tmpsite::tmp_site} in the YAML
#' header.
#'
#' @inheritParams rmarkdown::render_site
#'
#' @param ... Additional arguments (currently unused)
#'
#' @export
#'
tmp_site <- function(input, encoding = getOption("encoding"), ...) {

  render <- function(input_file,
                     output_format,
                     envir,
                     quiet,
                     encoding, ...) {

    input_file <- normalizePath(input_file)
    # Copy the entire project to /tmp
    dir_proj <- dirname(input_file)
    dir_upstream <- dirname(dir_proj)
    dir_tmp <- "/tmp"
    dir_new <- file.path(dir_tmp, basename(dir_proj))
    file.copy(from = dir_proj, to = dir_tmp, recursive = TRUE, overwrite = TRUE)
    file_tmp <- file.path(dir_new, basename(input_file))

    # Render the file
    rmarkdown::render(file_tmp,
                      output_format = output_format,
                      envir = envir,
                      quiet = quiet,
                      encoding = encoding)

    # Copy the entire project back
    file.copy(from = dir_new, to = dir_upstream, recursive = TRUE, overwrite = TRUE)

    # Open in RStudio Viewer
    if (!quiet) {
      output_file <- sub("[Rr]md$", "html", input_file)
      message("\nOutput created: ", output_file)
    }
  }

  # return site generator
  list(
    name = "ingore",
    output_dir = "ignore",
    render = render,
    clean = function() "Not implemented"
  )
}
