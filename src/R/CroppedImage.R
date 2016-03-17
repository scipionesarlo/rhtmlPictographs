#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
CroppedImage <- function(message, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    message = message
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'CroppedImage',
    x,
    width = width,
    height = height,
    package = 'CroppedImage'
  )
}

# #' Shiny bindings for CroppedImage
# #'
# #' Output and render functions for using CroppedImage within Shiny
# #' applications and interactive Rmd documents.
# #'
# #' @param outputId output variable to read from
# #' @param width,height Must be a valid CSS unit (like \code{'100\%'},
# #'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
# #'   string and have \code{'px'} appended.
# #' @param expr An expression that generates a CroppedImage
# #' @param env The environment in which to evaluate \code{expr}.
# #' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
# #'   is useful if you want to save an expression in a variable.
# #'
# #' @name CroppedImage-shiny
# #'
# #' @export
# CroppedImageOutput <- function(outputId, width = '100%', height = '400px'){
#   htmlwidgets::shinyWidgetOutput(outputId, 'CroppedImage', width, height, package = 'CroppedImage')
# }

# #' @rdname CroppedImage-shiny
# #' @export
# renderCroppedImage <- function(expr, env = parent.frame(), quoted = FALSE) {
#   if (!quoted) { expr <- substitute(expr) } # force quoted
#   htmlwidgets::shinyRenderWidget(expr, CroppedImageOutput, env, quoted = TRUE)
# }

