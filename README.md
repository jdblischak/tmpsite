# Render your R Markdown documents in a temporary directory

## Problem

Pandoc has a known bug where it will occasionally error when running on a file
located on a Windows share mounted on a Linux machine. This affects R Markdown
documents because they are passed to Pandoc after knitting with knitr.

## Solution

A potential solution is to first copy the R Markdown file and all its supporting
files to a temporary directory on the Linux machine, render the document there,
and then copy everything back to the original directory in the Windows share.

tmpsite is a prototype R package that uses a [custom site
generator](http://rmarkdown.rstudio.com/rmarkdown_site_generators.html),
`tmp_site`, to accomplish this. To start rendering in a temporary directory,
install the package from GitHub and then run the one-time setup in the directory
that contains the R Markdown files.

```r
devtools::intall_github("jdblischak/tmpsite")
tmpsite::render_rmd_in_tmp()
```

To ensure this works:

* If using the RStudio Knit button, make sure the Knit Directory is set to the
Document Directory

* If using the R console, run `render_site` in place of `render`

## How this works

If RStudio sees a file named `index.Rmd` in the same working directory, it will
search this for a site generator. Thus placing an otherwise empty `index.Rmd`
file that specifies to use `tmp_site` as the generator is sufficient to override
the normal rendering process.

## Room for improvement

This is just a quick prototype. Potentially by setting the Knit Directory, it
may be possible to only copy the R Markdown file to the temporary directory (as
opposed to the entire directory as is currently done). This would have multiple
benefits: 1) faster because less to copy and 2) paths to files outside of the
project directory could be used.

Another limitation is that `tmp_site` currently only supports rendering one file
at a time, and thus will throw an error if provided a directory. This was done
out of convenience and it would be straightforward to enhance the functionality
to be similar to `rmarkdown::default_site`.

## License

This code is in the public domain, i.e.
[CC0](https://creativecommons.org/share-your-work/public-domain/cc0).
