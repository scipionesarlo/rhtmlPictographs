#' rhtmlPictographs HTML Widget
#'
#' @description A HTMLWidget that can generate single image graphics, mutli image graphics, or a table of single/multi image graphics. See scenarios and examples below for different use cases.
#'
#' @section Usage Scenarios:
#'
#' Scenario 1: Single graphic containing one or more image
#' One or more image URLs are provided, a base and a variable image.
#' The image will be repeatedly drawn to form a grid based on the provided image count (numImages), number of rows (numRows), number of columns (numCols).
#' The variable image is cropped vertically or horizontally to create a partially displayed image representing the provided percentage value.
#' If the base image is provided it will be fully rendered "underneath" the variable image.
#' A text header, text overlay, and/or text header can be provided to annotate the graphic.
#'
#' By default the widget will fill attempt to fill 100% of the containing DOM element, and can be resized by resizing the outer container.
#' In displayr this resizing can be done simply by dragging the graphic to make it smaller or larger
#' If the resizable param is set to 'false', the resizing is disabled.
#'
#' TODO : These docs need updating !
#'
#' @param percentage Numeric between 0 and 1. Default 1.
#' @param width Positive numeric representing desired width of graphic
#' @param height Positive numeric representing desired height of graphic. Note that specified height will be total height including header and footer text banners.
#' @param settingsJsonString A valid JSON string containing the following params:
#' \itemize{
#'   \item direction: ("horizontal"|"vertical"|"scale") - default horizontal. Indicates direction of cropping. Scale will cause image to shrink based on percentage provided
#'   \item numImages: integer - default 1. The number of images to display.
#'   \item numRows: integer - optional. default unset. The number of rows in the grid. Must be <= numImages. Cannot set numRows and numCols (use numImages) !
#'   \item numCols: integer - optional. default unset. The number of cols in the grid. Must be <= numImages. Cannot set numRows and numCols (use numImages) !
#'   \item baseImageUrl: URL - optional. default unset. The URL (including http://) of baseImage
#'   \item variableImageUrl: URL - required. The URL (including http://) of variableImageUrl
#'   \item background-color: string - optional. default unset. Set a background color under both images
#'   \item text-overlay: - string - optional. default unset. A string to display overlaid over the center of the graphic. If string set to 'percentage' then the numeric percentage will be displayed
#'   \item text-header: string - optional. default unset. Text to display above graphic
#'   \item font-family: css - optional. default 'Verdana,sans-serif'. Controls font. See : https://developer.mozilla.org/en/docs/Web/CSS/font-family
#'   \item font-weight: css - optional. default 900. Controls font thickness. See : https://developer.mozilla.org/en/docs/Web/CSS/font-weight
#'   \item font-size: css - optional. default 24px. Controls font size. See : https://developer.mozilla.org/en/docs/Web/CSS/font-size
#'   \item font-color: css - optional. default black. Controls font color. Note this maps to the css 'color' property. See : https://developer.mozilla.org/en/docs/Web/CSS/color
#'   \item tooltip: string - optional. default unset. A string to display on mouse hover over the graphic
#'   \item resizable: string - optional. default true. Options [true|false]. For now, make sure it is a string not a boolean. TODO: accept R booleans accross function boundary
#'   \item preserveAspectRatio: string - optional. default unset. If set, the exact value will be used for the preserveAspectRatio property of the outer SVG. See here for docs: https://developer.mozilla.org/en/docs/Web/SVG/Attribute/preserveAspectRatio
#'   \item columnGutter: number between 0 and 1. default 0.05. Set the ratio of the padding between columns to the image size. Note that at 0.5 the padding is equal to the width of the image. For more info, this parameter sets the padding value of the call to .rangebands : https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal_rangeBands
#'   \item rowGutter: number between 0 and 1. default 0.05. Set the ratio of the padding between rows to the image size. Note that at 0.5 the padding is equal to the width of the image. For more info, this parameter sets the padding value of the call to .rangebands : https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal_rangeBands
#'   \item debugBorder: existence - optional. default unset. Set this key to anything, and then debug borders will be drawn
#' }
#'
#' @examples
#'
#' single horizontally cropped image - minimal settings
#' rhtmlPictographs::graphic('{"variableImage":"circle:horizontal:blue","percentage":"0.4","width":400,"height":400}')
#'
#' @author Kyle Zeeuwen <kyle.zeeuwen@gmail.com>
#'
#' @source https://github.com/NumbersInternational/rhtmlPictographs
#'
#' @import htmlwidgets
#'
#' @export
#'

graphic <- function(settingsJsonString = '{}') {

  DEFAULT_WIDGET_WIDTH <- 600
  DEFAULT_WIDGET_HEIGHT <- 600

  width <- DEFAULT_WIDGET_WIDTH
  height <- DEFAULT_WIDGET_HEIGHT

  if (grepl('^\\{', settingsJsonString)) {

    parsedInput <- NULL
    parsedInput = tryCatch({
      jsonlite::fromJSON(settingsJsonString)
    }, warning = function(w) {
      print("warning while parsing JSON:")
      print(w)
    }, error = function(e) {
      print("error while parsing JSON:")
      print(e)
      stop(e)
    }, finally = {})

    if('width' %in% names(parsedInput)) {
      width <- as.numeric(unlist(parsedInput['width']))
    }

    if('height' %in% names(parsedInput)) {
      height <- as.numeric(unlist(parsedInput['height']))
    }
  }

  htmlwidgets::createWidget(
    name = 'rhtmlPictographs',
    settingsJsonString,
    width = width,
    height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = DEFAULT_WIDGET_WIDTH,
      defaultHeight = DEFAULT_WIDGET_HEIGHT,
      browser.fill = TRUE,
      viewer.fill = TRUE,
      padding = 0
    ),
    package = 'rhtmlPictographs'
  )
}
