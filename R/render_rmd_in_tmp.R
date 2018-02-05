

#' One time setup to render R Markdown files in temporary directory
#'
#' To render your R Markdown documents in a temporary directory, you need to add
#' a file \code{index.Rmd} that specifies \code{site: tmpsite::tmp_site} in the
#' YAML header. \code{build_rmd_in_tmp} creates this file.
#'
#' @param directory The path to the directory that contains the R Markdown files
#'   that should be rendered in a temporary directory. Default is current
#'   working directory.
#'
#' @seealso \code{\link{tmp_site}}
#'
#' @export
#'
render_rmd_in_tmp <- function(directory = ".") {
  stopifnot(dir.exists(directory))
  header <- c("---",
              "site: tmpsite::tmp_site",
              "---")
  index <- file.path(directory, "index.Rmd")
  if (file.exists(index))
    stop("index.Rmd already exists in ", normalizePath(directory))
  writeLines(header, index)
  return(invisible(index))
}
