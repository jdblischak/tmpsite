

#' Custom site generator to render in in a temporary directory
#'
#' To render your R Markdown documents in a temporary directory, run
#' \code{\link{render_rmd_in_tmp}} in the directory that contains the R Markdown
#' files. Afterwards, using the RStudio Knit button will automatically use this
#' custom site generator. If you receive an error from RStudio, make sure the
#' Knit Directory is set to Document Directory (you can set this with the
#' dropdown menu next to the Knit button).
#'
#' If you render the file from the R console, use
#' \code{\link[rmarkdown]{render_site}}. If you specify the
#' \code{output_format}, it is preferred to pass a character vector, e.g.
#' \code{"html_document"}, instead of the object itself, e.g.
#' \code{html_document()}.
#'
#' @inheritParams rmarkdown::render_site
#'
#' @param ... Additional arguments (currently unused)
#'
#' @seealso \code{\link{render_rmd_in_tmp}},
#'   \code{\link[rmarkdown]{render_site}}
#' @export
#' @examples
#' \dontrun{
#'
#' library("rmarkdown")
#' render_site("example.Rmd", "html_document")
#' render_site("example.Rmd", "pdf_document")
#' render_site("example.Rmd", "word_document")
#' }
tmp_site <- function(input, encoding = getOption("encoding"), ...) {

  render <- function(input_file,
                     output_format,
                     envir,
                     quiet,
                     encoding, ...) {


    input_file_w_path <- normalizePath(input_file)
    # Copy the entire project to temporary directory
    dir_proj <- dirname(input_file_w_path)
    dir_upstream <- dirname(dir_proj)
    dir_tmp <- tempfile("tmp_site-")
    dir.create(dir_tmp)
    dir_new <- file.path(dir_tmp, basename(dir_proj))
    file.copy(from = dir_proj, to = dir_tmp, recursive = TRUE, overwrite = TRUE)
    file_tmp <- file.path(dir_new, basename(input_file))

    # Render the file
    suppressMessages(rmarkdown::render(file_tmp,
                      output_format = output_format,
                      envir = envir,
                      quiet = quiet,
                      encoding = encoding))

    # Copy the entire project back
    file.copy(from = dir_new, to = dir_upstream, recursive = TRUE, overwrite = TRUE)

    # Remove temporary directory
    unlink(dir_tmp, recursive = TRUE)

    # Figure out the format of the output document. By default it is NULL, so it
    # needs to be read from the YAML header. Alternatively, the user can choose
    # a format other than the first one listed in the header by passing a
    # string, e.g. "html_document" or a function, e.g. html_document().
    if (is.null(output_format)) {
      # Read the YAML header
      header <- rmarkdown::yaml_front_matter(input_file)
      output_format <- names(header$output)[1]
    } else if (class(output_format) == "rmarkdown_output_format") {
      # If it's an object, send warning that it'd work better if they passed a
      # string
      warning("For tmp_site, it is preferred to pass a character vector,",
              "e.g. \"html_document\", instead of the object itself,",
              "e.g. html_document()")
    }

    if (!quiet && is.character(output_format)) {
      if (output_format == "word_document") {
        extension <- "docx"
      } else {
        extension <- unlist(strsplit(output_format, "_"))[1]
      }
      output_file <- sub("[Rr]md$", extension, input_file)
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
